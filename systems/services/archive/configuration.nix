{ config, pkgs, ... }:
{
    users.users.archivebox = {
        isSystemUser = true;
        group = "archivebox";
        shell = pkgs.zsh;
    };
    users.groups.archivebox = { };
    ensurePaths.folders = {
        "/shared/data/archive" = { };
        "/shared/systems/services/archive" = { };
        "/shared/systems/services/archive/sonic" = { };
    };
    secrets.secrets = {
        "archivebox/admin_username" = { };
        "archivebox/admin_password" = { };
        "archivebox/search_backend_password" = { };
    };

    sops.templates."archivebox.env".content = ''
        ADMIN_USERNAME=${config.sops.placeholder."archivebox/admin_username"}
        ADMIN_PASSWORD=${config.sops.placeholder."archivebox/admin_password"}
        SEARCH_BACKEND_PASSWORD=${config.sops.placeholder."archivebox/search_backend_password"}
    '';

    sops.templates."sonic.env".content = ''
        SEARCH_BACKEND_PASSWORD=${config.sops.placeholder."archivebox/search_backend_password"}
    '';

    sops.templates."scheduler.env".content = ''
        SEARCH_BACKEND_PASSWORD=${config.sops.placeholder."archivebox/search_backend_password"}
    '';
    networking.firewall.allowedTCPPorts = [ 8000 ];

    virtualisation.oci-containers.containers = {
        archivebox = {
            image = "archivebox/archivebox:latest";
            ports = [ "0.0.0.0:8000:8000" ];
            volumes = [
                "/shared/data/archive:/data/archive"
                "/shared/systems/services/archive:/data"
            ];
            environmentFiles = [ config.sops.templates."archivebox.env".path ];
            environment = {
                ALLOWED_HOSTS = "*";
                CSRF_TRUSTED_ORIGINS = "https://archive.dax.gay";
                PUBLIC_INDEX = "True";
                PUBLIC_SNAPSHOTS = "True";
                PUBLIC_ADD_VIEW = "True";
                SEARCH_BACKEND_ENGINE = "sonic";
                SEARCH_BACKEND_HOST_NAME = "sonic";
                SAVE_ARCHIVEDOTORG = "True";
                USER_AGENT = "Mozilla/5.0 (compatible; Konqueror/4.3; Linux) KHTML/4.3.1 (like Gecko) Fedora/4.3.1-3.fc11";
                PUID = toString config.users.users.archivebox.uid;
                PGID = toString config.users.groups.archivebox.gid;
                TIMEOUT = "120";
            };
            user = "archivebox:archivebox";
            autoStart = true;
        };

        archivebox_scheduler = {
            image = "archivebox/archivebox:latest";
            cmd = [
                "schedule"
                "--foreground"
                "--update"
                "--every=day"
            ];
            environmentFiles = [ config.sops.templates."scheduler.env".path ];
            environment = {
                SEARCH_BACKEND_ENGINE = "sonic";
                SEARCH_BACKEND_HOST_NAME = "sonic";
                SAVE_ARCHIVEDOTORG = "True";
                USER_AGENT = "Mozilla/5.0 (compatible; Konqueror/4.3; Linux) KHTML/4.3.1 (like Gecko) Fedora/4.3.1-3.fc11";
                PUID = toString config.users.users.archivebox.uid;
                PGID = toString config.users.groups.archivebox.gid;
                TIMEOUT = "120";
            };
            volumes = [ "/shared/systems/services/archive:/data" ];
            user = "archivebox:archivebox";
            autoStart = true;
        };

        sonic = {
            image = "archivebox/sonic:latest";
            extraOptions = [ "--expose=1491" ];
            volumes = [
                "/shared/systems/services/archive/sonic:/var/lib/sonic/store"
            ];
            environmentFiles = [ config.sops.templates."sonic.env".path ];
            autoStart = true;
        };
    };
}
