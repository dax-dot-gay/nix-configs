{ config, lib, ... }:
{
    secrets.secrets = {
        "authentik/secret_key" = {
            hosts = [ "infra-authentik" ];
        };
        "authentik/email_password" = {
            hosts = [ "infra-authentik" ];
        };
    };

    sops.templates."authentik.env".content = ''
        AUTHENTIK_SECRET_KEY=${config.sops.placeholder."authentik/secret_key"}
        AUTHENTIK_EMAIL__PASSWORD=${config.sops.placeholder."authentik/email_password"}
    '';

    ensurePaths.folders = {
        "/persistent/postgresql" = {
            owner = "postgres";
            group = "postgres";
            mode = "750";
        };
        "/shared/systems/infra/authentik/blueprints" = { };
        "/shared/systems/infra/authentik/templates" = { };
        "/shared/systems/infra/authentik/media" = { };
    };

    services = {
        authentik = {
            enable = true;
            createDatabase = true;
            environmentFile = config.sops.templates."authentik.env".path;
            settings = {
                blueprints_dir = lib.mkOverride 10 "/shared/systems/infra/authentik/blueprints";
                template_dir = lib.mkOverride 10 "/shared/systems/infra/authentik/templates";
                storage.media.file = lib.mkOverride 10 { path = "/shared/systems/infra/authentik/media"; };
                media.enableUpload = true;
                email = {
                    host = "mail.smtp2go.com";
                    port = 443;
                    username = "auth.dax.gay";
                    use_tls = false;
                    use_ssl = true;
                    from = "Lesbos SSO <sso@dax.gay>";
                };
                avatars = "initials";
                disable_startup_analytics = true;
                log_level = "debug";
                cookie_domain = "dax.gay";
                listen = {
                    http = "0.0.0.0:9000";
                    metrics = "0.0.0.0:9300";
                    trusted_proxy_cidrs = "192.168.30.0/24";
                };
            };
            nginx.enable = false;
        };

        postgresql.dataDir = "/persistent/postgresql";
    };

    networking.firewall.allowedTCPPorts = [
        9000
        9300
    ];
}
