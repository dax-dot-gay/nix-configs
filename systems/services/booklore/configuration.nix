{ config, ... }:
{
    lesbos = {
        volumes."/vol/booklore" = {
            path = "systems/services/booklore/data";
        };
        volumes."/vol/mysql" = {
            path = "systems/services/booklore/mysql";
            mode = "750";
        };
        volumes."/vol/bookdrop" = {
            path = "data/media/Library/booklore/bookdrop";
        };
        volumes."/vol/library" = {
            path = "data/media/Library/booklore/library";
        };
    };

    secrets.secrets."booklore/db_password" = {};
    sops.templates."booklore.env".content = ''
        DATABASE_PASSWORD=${config.sops.placeholder."booklore/db_password"}
    '';
    sops.templates."mysql.env".content = ''
        MYSQL_ROOT_PASSWORD=${config.sops.placeholder."booklore/db_password"}
        MYSQL_PASSWORD=${config.sops.placeholder."booklore/db_password"}
    '';

    networking.firewall.allowedTCPPorts = [ 6060 ];

    virtualisation.oci-containers.containers = {
        booklore = {
            image = "booklore/booklore:latest";
            dependsOn = [ "mariadb" ];
            ports = [ "0.0.0.0:6060:6060" ];
            volumes = [
                "/vol/booklore:/app/data"
                "/vol/library:/books"
                "/vol/bookdrop:/bookdrop"
            ];
            user = "root:root";
            environmentFiles = [ config.sops.templates."booklore.env".path ];
            environment = {
                USER_ID = "0";
                GROUP_ID = "0";
                TZ = "US/Eastern";
                DATABASE_URL = "jdbc:mariadb://mariadb:3306/booklore";
                DATABASE_USERNAME = "booklore";
                BOOKLORE_PORT = "6060";
            };
            autoStart = true;
        };
        mariadb = {
            image = "lscr.io/linuxserver/mariadb:11.4.5";
            autoStart = true;
            volumes = [ "/vol/mysql:/config" ];
            environmentFiles = [ config.sops.templates."mysql.env".path ];
            user = "root:root";
            environment = {
                PUID = "0";
                PGID = "0";
                TZ = "US/Eastern";
                MYSQL_DATABASE = "booklore";
                MYSQL_USER = "booklore";
            };
        };
    };
}
