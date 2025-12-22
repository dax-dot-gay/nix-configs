{ config, ... }:
{
    secrets.secrets."authelia/config.yaml" = {
        sopsFile = ../../../secrets/authelia.yaml;
        format = "yaml";
        key = "";
        hosts = [ "infra-authelia" ];
    };
    ensurePaths.folders = {
        "/shared/systems/infra/authelia" = {};
        "/shared/systems/infra/authelia/assets" = {};
    };
    virtualisation.oci-containers.containers.authelia = {
        autoStart = true;
        volumes = [
            "${config.sops.secrets."authelia/config.yaml".path}:/config/config.yml"
            "/shared/systems/infra/authelia:/authelia"
            "/shared/systems/infra/authelia/assets:/authelia/assets"
        ];
        ports = [
            "0.0.0.0:9091:9091"
            "0.0.0.0:9959:9959"
        ];
        image = "docker.io/authelia/authelia:latest";
        user = "root:root";
    };
    networking.firewall.allowedTCPPorts = [
        9091
        9959
    ];
}
