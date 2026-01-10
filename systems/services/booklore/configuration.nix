{ config, ... }:
let
    uid = toString config.lesbos.system_users.booklore.uid;
    gid = toString config.lesbos.system_users.booklore.gid;
in
{
    lesbos = {
        system_users.booklore = {
            uid = 981;
            gid = 981;
        };
        volumes."/vol/booklore" = {
            path = "systems/services/booklore";
            subpaths = [
                "data"
                "mysql"
            ];
            owner = "booklore";
            group = "booklore";
            mode = "777";
        };
        volumes."/vol/bookdrop" = {
            path = "data/media/Library/booklore/bookdrop";
            owner = "booklore";
            group = "booklore";
            mode = "777";
        };
        volumes."/vol/library" = {
            path = "data/media/Library/booklore/library";
            owner = "booklore";
            group = "booklore";
            mode = "777";
        };
    };

    secrets.secrets."booklore/db_password" = {
        owner = "booklore";
        group = "booklore";
        mode = "777";
    };
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
                "/vol/booklore/data:/app/data"
                "/vol/library:/books"
                "/vol/bookdrop:/bookdrop"
            ];
            user = "${uid}:${gid}";
            environmentFiles = [ config.sops.templates."booklore.env".path ];
            environment = {
                USER_ID = uid;
                GROUP_ID = gid;
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
            volumes = [ "/vol/booklore/mysql:/config" ];
            environmentFiles = [ config.sops.templates."mysql.env".path ];
            user = "${uid}:${gid}";
            environment = {
                PUID = uid;
                PGID = gid;
                TZ = "US/Eastern";
                MYSQL_DATABASE = "booklore";
                MYSQL_USER = "booklore";
            };
        };
    };
}
