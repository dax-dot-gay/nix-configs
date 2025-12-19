{ pkgs, config, ... }:
{
    imports = [
        ./livekit.nix
        ./synapse.nix
        ./element_admin.nix
        ./cinny.nix
    ];

    # MAS user & persistent homedir
    users = {
        groups.matrix-authentication-service = { };
        users.matrix-authentication-service = {
            group = "matrix-authentication-service";
            isSystemUser = true;
            createHome = true;
            home = "/persistent/matrix-authentication-service";
        };
    };

    # Additional packages
    environment.systemPackages = with pkgs; [
        matrix-authentication-service
        compose2nix
        podman
        podman-compose
        livekit
    ];

    # Postgres
    services.postgresql = {
        enable = true;
        authentication = pkgs.lib.mkOverride 10 ''
            #type database  DBuser  auth-method
            local all       all     trust
            local all matrix-synapse trust
            local all matrix-authentication-service trust
            local all root trust
        '';
        dataDir = "/persistent/postgresql";
        ensureDatabases = [
            "matrix-authentication-service"
            "matrix-synapse"
        ];
    };
    networking.firewall.enable = false;

    systemd.services.matrix-authentication-service = {
        enable = true;
        before = [ "matrix-synapse.service" ];
        wantedBy = [ "multi-user.target" ];
        path = with pkgs; [
            coreutils
            matrix-authentication-service
        ];
        script = ''
            mas-cli server --config ${config.sops.secrets."matrix/matrix-authentication/config.yaml".path}
        '';
        serviceConfig = {
            RemainAfterExit = "yes";
            User = "matrix-authentication-service";
        };
    };

}
