{ config, ... }:
{
    secrets.secrets = {
        "romm/romm_auth_secret_key" = {
            mode = "444";
            hosts = [ "services-romm" ];
        };
        "romm/db/mariadb_root_password" = {
            mode = "444";
            hosts = [ "services-romm" ];
        };
        "romm/db/mariadb_password" = {
            mode = "444";
            hosts = [ "services-romm" ];
        };
        "romm/meta/igdb_client_id" = {
            mode = "444";
            hosts = [ "services-romm" ];
        };
        "romm/meta/igdb_client_secret" = {
            mode = "444";
            hosts = [ "services-romm" ];
        };
        "romm/meta/steamgriddb_api_key" = {
            mode = "444";
            hosts = [ "services-romm" ];
        };
        "romm/meta/retroachievements_api_key" = {
            mode = "444";
            hosts = [ "services-romm" ];
        };
    };

    sops.templates."romm/main.env" = {
        content = ''
            DB_HOST=host.docker.internal
            DB_NAME=romm
            DB_USER=romm-user
            DB_PASSWD=${config.sops.placeholder."romm/db/mariadb_password"}
            ROMM_AUTH_SECRET_KEY=${config.sops.placeholder."romm/romm_auth_secret_key"}
            RETROACHIEVEMENTS_API_KEY=${config.sops.placeholder."romm/meta/retroachievements_api_key"}
            STEAMGRIDDB_API_KEY=${config.sops.placeholder."romm/meta/steamgriddb_api_key"}
            HASHEOUS_API_ENABLED=true
            IGDB_CLIENT_ID=${config.sops.placeholder."romm/meta/igdb_client_id"}
            IGDB_CLIENT_SECRET=${config.sops.placeholder."romm/meta/igdb_client_secret"}
        '';
        mode = "444";
    };

    sops.templates."romm/mariadb.env" = {
        content = ''
            MARIADB_ROOT_PASSWORD=${config.sops.placeholder."romm/db/mariadb_root_password"}
            MARIADB_DATABASE=romm
            MARIADB_USER=romm-user
            MARIADB_PASSWORD=${config.sops.placeholder."romm/db/mariadb_password"}
        '';
        mode = "444";
    };

    virtualisation.oci-containers.containers = {
        romm = {
            image = "rommapp/romm:latest";
            autoStart = true;
            dependsOn = [ "romm-mariadb" ];
            ports = [ "0.0.0.0:8080:80" ];
            #volumes = [ "volume_name:/path/inside/container" "/path/on/host:/path/inside/container" ];
            volumes = [
                "/shared/systems/services/romm/resources:/romm/resources"
                "/shared/systems/services/romm/redis:/redis-data"
                "/shared/data/media/Games/ROMs:/romm/library"
                "/shared/data/media/Games/Assets:/romm/assets"
                "/shared/systems/services/romm/config:/romm/config"
            ];
            environmentFiles = [ config.sops.templates."romm/main.env".path ];
            user = "root:root";
        };
        romm-mariadb = {
            image = "mariadb:latest";
            autoStart = true;
            environmentFiles = [ config.sops.templates."romm/mariadb.env".path ];
            volumes = [ "/shared/systems/services/romm/mariadb:/var/lib/mysql" ];
            ports = [ "0.0.0.0:3306:3306" ];
            user = "root:root";
        };
    };

    networking.firewall.allowedTCPPorts = [ 8080 3306 ];
    ensurePaths.folders = {
        "/shared/systems/services/romm/resources" = {};
        "/shared/systems/services/romm/redis" = {};
        "/shared/data/media/Games/ROMs" = {};
        "/shared/data/media/Games/Assets" = {};
        "/shared/systems/services/romm/config" = {};
        "/shared/systems/services/romm/mariadb" = {};
    };
    ensurePaths.files."/shared/systems/services/romm/config/config.yml" = {};
}
