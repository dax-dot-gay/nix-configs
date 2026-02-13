{config, daxlib, ...}: let hosts = daxlib.hosts; in {
    secrets.secrets = {
        "nextcloud/database/user" = {owner = "nextcloud";};
        "nextcloud/database/password" = {owner = "nextcloud";};
        "nextcloud/database/database" = {owner = "nextcloud";};
        "nextcloud/admin/user" = {owner = "nextcloud";};
        "nextcloud/admin/password" = {owner = "nextcloud";};
    };
    sops.templates."nextcloud.env".content = ''
        POSTGRES_DB=${config.sops.placeholder."nextcloud/database/database"}
        POSTGRES_USER=${config.sops.placeholder."nextcloud/database/user"}
        POSTGRES_PASSWORD=${config.sops.placeholder."nextcloud/database/password"}
        NEXTCLOUD_ADMIN_USER=${config.sops.placeholder."nextcloud/admin/user"}
        NEXTCLOUD_ADMIN_PASSWORD=${config.sops.placeholder."nextcloud/admin/password"}
    '';
    sops.templates."nextcloud.env".owner = "nextcloud";
    lesbos.volumes."/vol/nextcloud" = {
        path = "systems/services/nextcloud";
        owner = "nextcloud";
        group = "nextcloud";
        subpaths = [
            "root"
            "custom_apps"
            "config"
            "data"
            "custom_themes"
        ];
    };
    lesbos.system_users.nextcloud = {uid = 33; gid = 33;};
    virtualisation.oci-containers.containers.nextcloud = {
        image = "nextcloud";
        ports = ["0.0.0.0:8080:8080"];
        user = "33:33";
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
            APACHE_LISTEN_PORT = "8080";
        };
    };
    networking.firewall.enable = false;
}