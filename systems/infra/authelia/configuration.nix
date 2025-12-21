{ config, ... }:
{
    secrets.secrets."authelia/config.yaml" = {
        sopsFile = ../../../secrets/authelia.yaml;
        format = "yaml";
        key = "";
        hosts = [ "infra-authelia" ];
        owner = "authelia";
        group = "authelia";
    };
    users.users.authelia = {
        isSystemUser = true;
        group = "authelia";
    };
    users.groups.authelia = {};
    ensurePaths.folders."/shared/systems/infra/authelia" = {
        owner = "authelia";
        group = "authelia";
        mode = "770";
    };
    ensurePaths.folders."/shared/systems/infra/authelia/assets" = {
        owner = "authelia";
        group = "authelia";
        mode = "770";
    };
    ensurePaths.folders."/shared/systems/infra/authelia/logs" = {
        owner = "authelia";
        group = "authelia";
        mode = "770";
    };
    ensurePaths.folders."/shared/systems/infra/authelia/users.yml" = {
        owner = "authelia";
        group = "authelia";
        mode = "770";
    };
    services.authelia.instances.main = {
        enable = true;
        user = "authelia";
        group = "authelia";
        name = "Lesbos SSO";
        settingsFiles = [ config.sops.secrets."authelia/config.yaml".path ];
        secrets.manual = true;
    };
    networking.firewall.enable = false;
}
