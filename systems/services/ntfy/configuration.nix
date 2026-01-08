{ config, ... }:
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
    services.ntfy-sh = {
        enable = true;
        user = "ntfy";
        group = "ntfy";
        settings = {
            base-url = "https://ntfy.dax.gay";
            listen-http = "0.0.0.0:2586";
            auth-file = "/vol/ntfy/auth.db";
            auth-default-access = "deny-all";
            behind-proxy = true;
            attachment-cache-dir = "/vol/ntfy/attachments";
            enable-signup = false;
            enable-login = true;
            enable-reservations = true;
            require-login = true;
        };
    };
}
