{
    lib,
    pkgs,
    config,
    ...
}:
let
    keyFile = "/run/livekit.key";
    escapeSystemdExecArg =
        arg:
        let
            s =
                if lib.isPath arg then
                    "${arg}"
                else if lib.isString arg then
                    arg
                else if lib.isInt arg || lib.isFloat arg || lib.isDerivation arg then
                    builtins.toString arg
                else
                    builtins.throw "escapeSystemdExecArg only allows strings, paths, numbers and derivations";
        in
        lib.replaceStrings [ "%" "$" ] [ "%%" "$$" ] (builtins.toJSON s);

    # Quotes a list of arguments into a single string for use in a Exec*
    # line.
    escapeSystemdExecArgs = lib.concatMapStringsSep " " escapeSystemdExecArg;
in
{
    sops.templates."services-matrix/livekit.json".content = ''
        {
            "rtc": {
                "tcp_port": 7881,
                "port_range_start": 48000,
                "port_range_end": 48999,
                "use_external_ip": false,
                "turn_servers": [
                    {
                        "host": "relay1.expressturn.com",
                        "port": 443,
                        "protocol": "tls",
                        "username": "${config.sops.placeholder."matrix/turn/username"}",
                        "credential": "${config.sops.placeholder."matrix/turn/credential"}"
                    }
                ]
            }
        }
    '';

    services.lk-jwt-service = {
        enable = true;
        livekitUrl = "wss://livekit.matrix.dax.gay";
        inherit keyFile;
    };
    systemd.services.lk-jwt-service.environment.LIVEKIT_FULL_ACCESS_HOMESERVERS = "matrix.dax.gay";
    systemd.services.livekit-key = {
        before = [
            "lk-jwt-service.service"
            "livekit.service"
        ];
        wantedBy = [ "multi-user.target" ];
        path = with pkgs; [
            livekit
            coreutils
            gawk
        ];
        script = ''
            if [ -f ${keyFile} ]; then
              echo "Key exists"
            else
              echo "Key missing, generating key"
              echo "lk-jwt-service: $(livekit-server generate-keys | tail -1 | awk '{print $3}')" > "${keyFile}"
            fi
        '';
        serviceConfig.Type = "oneshot";
    };
    systemd.services.livekit = {
        description = "LiveKit SFU server";
        documentation = [ "https://docs.livekit.io" ];
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];

        serviceConfig = {
            LoadCredential = [ "livekit-secrets:${keyFile}" ];
            ExecStart = escapeSystemdExecArgs [
                (lib.getExe pkgs.livekit)
                "--config="
                "--key-file=/run/credentials/livekit.service/livekit-secrets"
            ];
            DynamicUser = true;
            LockPersonality = true;
            MemoryDenyWriteExecute = true;
            ProtectClock = true;
            ProtectControlGroups = true;
            ProtectHostname = true;
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            PrivateDevices = true;
            PrivateMounts = true;
            PrivateUsers = true;
            RestrictAddressFamilies = [
                "AF_INET"
                "AF_INET6"
                "AF_NETLINK"
            ];
            RestrictNamespaces = true;
            RestrictRealtime = true;
            ProtectHome = true;
            SystemCallArchitectures = "native";
            SystemCallFilter = [
                "@system-service"
                "~@privileged"
                "~@resources"
            ];
            Restart = "on-failure";
            RestartSec = 5;
            UMask = "077";
        };
    };
}
