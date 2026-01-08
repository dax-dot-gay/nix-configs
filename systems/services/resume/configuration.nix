{
    config,
    daxlib,
    ...
}:
let
    hosts = daxlib.hosts;
in
{
    lesbos.volumes = {
        "/vol/resume-maker" = {
            path = "systems/services/resume-maker";
            mode = "777";
        };
    };
    secrets.secrets = {
        "resume-maker/minio/user" = {};
        "resume-maker/minio/pass" = {};
        "resume-maker/postgres/user" = {};
        "resume-maker/postgres/pass" = {};
        "resume-maker/token" = {};
        "resume-maker/access_secret" = {};
        "resume-maker/refresh_secret" = {};
    };
    sops.templates = {
        "minio.env".content = ''
            MINIO_ROOT_USER=${config.sops.placeholder."resume-maker/minio/user"}
            MINIO_ROOT_PASSWORD=${config.sops.placeholder."resume-maker/minio/pass"}
        '';
        "chrome.env".content = ''
            TIMEOUT=10000
            CONCURRENT=10
            TOKEN=${config.sops.placeholder."resume-maker/token"}
            EXIT_ON_HEALTH_FAILURE=true
            PRE_REQUEST_HEALTH_CHECK=true
        '';
        "resume.env".content = ''
            CHROME_TOKEN=${config.sops.placeholder."resume-maker/token"}
            DATABASE_URL=postgresql://${config.sops.placeholder."resume-maker/postgres/user"}:${
                config.sops.placeholder."resume-maker/postgres/pass"
            }@${hosts.ip "infra-database"}:5432/resume-maker
            ACCESS_TOKEN_SECRET=${config.sops.placeholder."resume-maker/access_secret"}
            REFRESH_TOKEN_SECRET=${config.sops.placeholder."resume-maker/refresh_secret"}
            STORAGE_ACCESS_KEY=${config.sops.placeholder."resume-maker/minio/user"}
            STORAGE_SECRET_KEY=${config.sops.placeholder."resume-maker/minio/pass"}
        '';
    };
    networking.firewall.allowedTCPPorts = [
        3000
        9000
    ];
    virtualisation.oci-containers.containers = {
        minio = {
            image = "minio/minio:latest";
            autoStart = true;
            cmd = [
                "server"
                "/data"
            ];
            ports = [ "0.0.0.0:9000:9000" ];
            volumes = [ "/vol/resume-maker:/data:rw" ];
            user = "root:root";
            environmentFiles = [ "${config.sops.templates."minio.env".path}" ];
        };
        chrome = {
            image = "ghcr.io/browserless/chromium:v2.18.0";
            autoStart = true;
            extraOptions = [
                "--add-host=host.containers.internal:host-gateway"
            ];
            environmentFiles = [ "${config.sops.templates."chrome.env".path}" ];
            user = "root:root";
        };
        resume-maker = {
            image = "amruthpillai/reactive-resume:latest";
            autoStart = true;
            ports = [ "0.0.0.0:3000:3000" ];
            dependsOn = [
                "minio"
                "chrome"
            ];
            user = "root:root";
            environment = {
                PORT = "3000";
                NODE_ENV = "production";
                PUBLIC_URL = "https://resume.dax.gay";
                STORAGE_URL = "https://resume.dax.gay/minio";
                CHROME_URL = "ws://chrome:3000";
                MAIL_FROM = "noreply@localhost";
                STORAGE_ENDPOINT = "minio";
                STORAGE_PORT = "9000";
                STORAGE_BUCKET = "default";
                STORAGE_USE_SSL = "false";
                STORAGE_SKIP_BUCKET_CHECK = "false";
            };
            environmentFiles = [ "${config.sops.templates."resume.env".path}" ];
        };
    };
}
