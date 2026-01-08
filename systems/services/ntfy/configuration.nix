{ config, pkgs, ... }:
{
    lesbos.system_users.ntfy = { };
    lesbos.volumes."/vol/ntfy" = {
        path = "systems/services/ntfy";
        owner = "ntfy";
        group = "ntfy";
        subpaths = [ "attachments" ];
    };
    secrets.secrets = {
        "ntfy/user" = {
            owner = "ntfy";
            group = "ntfy";
        };
        "ntfy/pass" = {
            owner = "ntfy";
            group = "ntfy";
        };
    };
    networking.firewall.allowedTCPPorts = [ 2586 ];
    environment.systemPackages = [pkgs.sqlite];
    services.ntfy-sh = {
        enable = true;
        user = "ntfy";
        group = "ntfy";
        settings = {
            base-url = "https://ntfy.dax.gay";
            listen-http = "0.0.0.0:2586";
            auth-file = "/vol/ntfy/auth.db";
            cache-file = "/vol/ntfy/cache.db";
            auth-default-access = "deny-all";
            behind-proxy = true;
            attachment-cache-dir = "/vol/ntfy/attachments";
            enable-signup = false;
            enable-login = true;
            enable-reservations = true;
            require-login = true;
        };
    };
    systemd.services."ntfy-sh" = {
        serviceConfig = {
            ReadWritePaths = ["/vol/ntfy"];
        };
        postStart = ''
            NTFY_USER=$(echo ${config.sops.secrets."ntfy/user".path})
            NTFY_PASSWORD=$(echo ${config.sops.secrets."ntfy/pass".path})

            set +e
            ntfy user --auth-file /vol/ntfy/auth.db add --role=admin $NTFY_USER
        '';
        path = [pkgs.ntfy-sh];
    };
}
