{config, daxlib, ...}: let hosts = daxlib.hosts; in {
    secrets.secrets = {
        "nextcloud/database/user" = {};
        "nextcloud/database/password" = {};
        "nextcloud/database/database" = {};
        "nextcloud/admin/user" = {};
        "nextcloud/admin/password" = {};
    };
    sops.templates."nextcloud.env".content = ''
        POSTGRES_DB=${config.sops.placeholder."nextcloud/database/database"}
        POSTGRES_USER=${config.sops.placeholder."nextcloud/database/user"}
        POSTGRES_PASSWORD=${config.sops.placeholder."nextcloud/database/password"}
        NEXTCLOUD_ADMIN_USER=${config.sops.placeholder."nextcloud/admin/user"}
        NEXTCLOUD_ADMIN_PASSWORD=${config.sops.placeholder."nextcloud/admin/password"}
    '';
    lesbos.volumes."/vol/nextcloud" = {
        path = "systems/services/nextcloud";
        subpaths = [
            "root"
            "custom_apps"
            "config"
            "data"
            "custom_themes"
        ];
    };
    virtualisation.oci-containers.containers.nextcloud = {
        image = "nextcloud";
        ports = ["0.0.0.0:80:80"];
        user = "root:root";
        volumes = [
            "/vol/nextcloud/root:/var/www/html"
            "/vol/nextcloud/custom_apps:/var/www/html/custom_apps"
            "/vol/nextcloud/config:/var/www/html/config"
            "/vol/nextcloud/data:/var/www/html/data"
        ];
        environmentFiles = [
            config.sops.templates."nextcloud.env".path
        ];
        environment = {
            POSTGRES_HOST = "${hosts.ip "infra-database"}";
            NEXTCLOUD_TRUSTED_DOMAINS = "cloud.dax.gay dax.gay";
            PHP_UPLOAD_LIMIT = "64G";
            PHP_MEMORY_LIMIT = "1G";
        };
    };
    networking.firewall.enable = false;
}