{ config, lib, pkgs, ... }:
{
    secrets.secrets = {
        "authentik/secret_key" = {
            hosts = [ "infra-authentik" ];
        };
        "authentik/email_password" = {
            hosts = [ "infra-authentik" ];
        };
        "authentik/admin_password" = {
            hosts = [ "infra-authentik" ];
        };
        "authentik/admin_token" = {
            hosts = [ "infra-authentik" ];
        };
        "authentik/admin_email" = {
            hosts = [ "infra-authentik" ];
        };
    };

    sops.templates."authentik.env".content = ''
        AUTHENTIK_SECRET_KEY=${config.sops.placeholder."authentik/secret_key"}
        AUTHENTIK_EMAIL__PASSWORD=${config.sops.placeholder."authentik/email_password"}
        AUTHENTIK_BOOTSTRAP_PASSWORD=${config.sops.placeholder."authentik/admin_password"}
        AUTHENTIK_BOOTSTRAP_EMAIL=${config.sops.placeholder."authentik/admin_email"}
        AUTHENTIK_BOOTSTRAP_TOKEN=${config.sops.placeholder."authentik/admin_token"}
    '';

    system.activationScripts = {
      mkdirs = ''
        mkdir -p /shared/systems/infra/authentik/blueprints
        mkdir -p /shared/systems/infra/authentik/templates
        mkdir -p /shared/systems/infra/authentik/media
        mkdir -p /persistent/postgresql

        chown -R postgres:postgres /persistent/postgresql
        chmod -R 750 /persistent/postgresql
      '';
    };

    users.users.authentik = {
        isSystemUser = true;
        shell = pkgs.zsh;
        group = "authentik";
        createHome = true;
    };

    users.groups.authentik = {};

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
