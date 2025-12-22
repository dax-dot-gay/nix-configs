{ config, ... }:
{
    secrets.secrets."authelia/config.yaml" = {
        sopsFile = ../../../secrets/authelia.yaml;
        format = "yaml";
        key = "";
        hosts = [ "infra-authelia" ];
    };
    users.groups.authelia = {};
    ensurePaths.folders."/shared/systems/infra/authelia/assets" = {};
    ensurePaths.files."/shared/systems/infra/authelia/users.yml" = {};
    services.authelia.instances.lesbosso = {
        enable = true;
        user = "root";
        group = "root";
        settingsFiles = [ config.sops.secrets."authelia/config.yaml".path ];
        secrets.manual = true;
    };
    networking.firewall.enable = false;
}
