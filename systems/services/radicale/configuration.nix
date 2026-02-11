{ config, ... }:
{
    services.radicale = {
        enable = true;
        settings = {
            auth = {
                type = "htpasswd";
                htpasswd_filename = "${config.sops.secrets."radicale/users".path}";
                htpasswd_encryption = "plain";
            };
            server = {
                hosts = [
                    "0.0.0.0:5232"
                    "[::]:5232"
                ];
                max_connections = 100;
            };
            storage.filesystem_folder = "/vol/radicale";
        };
        rights = {
            root = {
                user = ".+";
                collection = "";
                permissions = "R";
            };
            principal = {
                user = ".+";
                collection = "{user}";
                permissions = "RW";
            };
            calendars = {
                user = ".+";
                collection = "{user}/[^/]+";
                permissions = "rw";
            };

        };
    };
    networking.firewall.allowedTCPPorts = [ 5232 ];
    secrets.secrets."radicale/users" = {
        owner = "radicale";
        group = "radicale";
    };
    lesbos.volumes."/vol/radicale" = {
        owner = "radicale";
        group = "radicale";
        path = "systems/services/radicale";
    };
}
