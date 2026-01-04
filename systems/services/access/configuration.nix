{ config, pkgs, lib, ... }:
{
    ensurePaths.folders."/shared/systems/services/access" = {};
    ensurePaths.folders."/shared/data/users" = {};
    ensurePaths.folders."/shared/data/public" = {};
    secrets.secrets = {
        "files/oidc/client_id" = {};
        "files/oidc/client_secret" = {};
        "files/oidc/config_url" = {};
        "files/admin_user" = {};
        "files/admin_password" = {};
    };

    sops.templates."sftpgo.env".content = ''
        SFTPGO_HTTPD__BINDINGS__0__OIDC__CLIENT_ID="${config.sops.placeholder."files/oidc/client_id"}"
        SFTPGO_HTTPD__BINDINGS__0__OIDC__CLIENT_SECRET="${config.sops.placeholder."files/oidc/client_secret"}"
        SFTPGO_HTTPD__BINDINGS__0__OIDC__CONFIG_URL="${config.sops.placeholder."files/oidc/config_url"}"
        SFTPGO_DEFAULT_ADMIN_USERNAME="${config.sops.placeholder."files/admin_user"}"
        SFTPGO_DEFAULT_ADMIN_PASSWORD="${config.sops.placeholder."files/admin_password"}"
    '';

    systemd.services.sftpgo.serviceConfig = {
        EnvironmentFile = config.sops.templates."sftpgo.env".path;
    };

    networking.firewall.enable = false;

    environment.systemPackages = [ pkgs.jq ];
    
    services.sftpgo = {
        enable = true;
        user = "root";
        group = "root";
        dataDir = "/shared/systems/services/access";
        settings = {
            sftpd = {
                bindings = [
                    {
                        port = 2022;
                        address = "0.0.0.0";
                    }
                ];
                password_authentication = false;
            };
            httpd = {
                bindings = [
                    {
                        port = 8080;
                        address = "0.0.0.0";
                        oidc = {
                            redirect_base_url = "https://fs.dax.gay";
                            username_field = "preferred_username";
                        };
                        security = {
                            enabled = true;
                        };
                        branding = {
                            name = "Lesbos File Share";
                            short_name = "Lesbos FS";
                        };
                    }
                ];
            };
            telemetry = {
                bind_port = 8081;
                bind_address = "0.0.0.0";
                enable_profiler = true;
            };
            defender = {
                enabled = true;
            };
            data_provider = {
                driver = "bolt";
                name = "/shared/systems/services/access/sftpgo.db";
                create_default_admin = true;
                users_base_dir = "/shared/data/users";
                pre_login_hook = pkgs.writeShellScriptBin "pre-login-hook" (lib.readFile ./pre-login-hook.sh);
            };
        };
    };
}
