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
        "authentik/ldap_token" = {
            hosts = [ "infra-authentik" ];
        };
        "authentik/proxy_token" = {
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

    sops.templates."authentik-ldap.env".content = ''
        AUTHENTIK_TOKEN=${config.sops.placeholder."authentik/ldap_token"}
        AUTHENTIK_HOST=https://auth.dax.gay
        AUTHENTIK_INSECURE=False
    '';

    sops.templates."authentik-proxy.env".content = ''
        AUTHENTIK_TOKEN=${config.sops.placeholder."authentik/proxy_token"}
        AUTHENTIK_HOST=https://auth.dax.gay
        AUTHENTIK_INSECURE=False
    '';

    ensurePaths.folders = {
        "/shared/systems/infra/authentik/media" = {};
        "/persistent/postgresql" = {
            owner = "postgres";
            group = "postgres";
            mode = "0750";
        };
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

        authentik-ldap = {
            enable = true;
            environmentFile = config.sops.templates."authentik-ldap.env".path;
        };

        authentik-proxy = {
            enable = true;
            environmentFile = config.sops.templates."authentik-proxy.env".path;
            listenHTTP = "0.0.0.0:9005";
            listenHTTPS = "0.0.0.0:9004";
        };

        postgresql.dataDir = "/persistent/postgresql";
    };

    systemd.services.authentik.serviceConfig.ReadWritePaths = ["/shared/systems/infra/authentik/blueprints" "/shared/systems/infra/authentik/templates" "/shared/systems/infra/authentik/media"];
    systemd.services.authentik-worker.serviceConfig.ReadWritePaths = ["/shared/systems/infra/authentik/blueprints" "/shared/systems/infra/authentik/templates" "/shared/systems/infra/authentik/media"];
    systemd.services.authentik-migrate.serviceConfig.ReadWritePaths = ["/shared/systems/infra/authentik/blueprints" "/shared/systems/infra/authentik/templates" "/shared/systems/infra/authentik/media"];

    networking.firewall.allowedTCPPorts = [
        9000
        9300
        9004
        9005
        3389
    ];
}
