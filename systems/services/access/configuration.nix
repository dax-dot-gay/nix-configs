{ pkgs, daxlib, hostname, config, ... }:
let
    hosts = daxlib.hosts;
    settings = (pkgs.formats.yaml {}).generate "filebrowser.yml" {
        server = {
            disableUpdateCheck = true;
            disablePreviews = false;
            listen = "0.0.0.0";
            port = 8080;
            database = "/volume/filebrowser.db";
            sources = [
                {
                    path = "/shared";
                    name = "Filesystem Root";
                    config = {
                        denyByDefault = true;
                        defaultEnabled = false;
                        createUserDir = false;
                    };
                }
                {
                    path = "/shared/data";
                    name = "Data Storage";
                    config = {
                        denyByDefault = true;
                        defaultEnabled = false;
                        createUserDir = false;
                    };
                }
                {
                    path = "/shared/data/users";
                    name = "Personal Files";
                    config = {
                        denyByDefault = false;
                        defaultEnabled = true;
                        createUserDir = true;
                    };
                }
                {
                    path = "/shared/data/media";
                    name = "Media";
                    config = {
                        denyByDefault = false;
                        defaultEnabled = true;
                        createUserDir = false;
                    };
                }
            ];
            externalUrl = "https://fs.dax.gay";
            internalUrl = "http://${hosts.ip hostname}:8080";
            cacheDir = "/volume/cache";
            maxArchiveSize = 100;
        };
        auth = {
            tokenExpirationHours = 6;
            methods.password = {
                enabled = true;
                signup = false;
            };
            methods.oidc = {
                enabled = true;
                issuerUrl = "https://auth.dax.gay/application/o/fs-dax-gay/";
                scopes = "openid email profile";
                userIdentifier = "preferred_username";
                logoutRedirectUrl = "https://auth.dax.gay/application/o/fs-dax-gay/end-session/";
                createUser = true;
                adminGroup = "authentik-admin";
                groupsClaim = "groups";
            };
            adminUsername = "itec";
        };
        frontend = {
            name = "Lesbos - File Server";
            disableDefaultLinks = true;
            description = "File Storage: Powered by Lesbians!";
        };
    };
in
{
    ensurePaths.folders."/shared/systems/services/access" = {};
    ensurePaths.folders."/shared/systems/services/access/cache" = {};
    ensurePaths.folders."/shared/data/users" = {};
    ensurePaths.folders."/shared/data/public" = {};
    secrets.secrets = {
        "files/admin_password" = {hosts = ["services-access"];};
        "files/oidc_client_id" = {hosts = ["services-access"];};
        "files/oidc_client_secret" = {hosts = ["services-access"];};
        "files/jwt_secret" = {hosts = ["services-access"];};
        "files/totp_secret" = {hosts = ["services-access"];};
    };

    config.sops.templates."filebrowser.env".content = ''
        FILEBROWSER_ADMIN_PASSWORD=${config.sops.placeholder."files/admin_password"}
        FILEBROWSER_OIDC_CLIENT_ID=${config.sops.placeholder."files/oidc_client_id"}
        FILEBROWSER_OIDC_CLIENT_SECRET=${config.sops.placeholder."files/oidc_client_secret"}
        FILEBROWSER_JWT_TOKEN_SECRET=${config.sops.placeholder."files/jwt_token_secret"}
        FILEBROWSER_TOTP_SECRET=${config.sops.placeholder."files/totp_secret"}
        FILEBROWSER_CONFIG=/volume/config.yml
    '';
    
    virtualisation.oci-containers.containers.filebrowser = {
        autoStart = true;
        image = "gtstef/filebrowser:beta";
        volumes = [
            "/shared/systems/services/access:/volume"
            "/shared:/shared"
            "${settings}:/volume/config.yml"
        ];
        ports = ["0.0.0.0:8080:8080"];
        environmentFiles = [ config.sops.templates."filebrowser.yml".path ];
        user = "root:root";
    };
}
