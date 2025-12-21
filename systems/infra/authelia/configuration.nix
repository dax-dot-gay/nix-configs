{ ... }:
{
    secrets.secrets."authelia/config.yaml" = {
        sopsFile = ../../../secrets/authelia.yaml;
        format = "binary";
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
    };
    /*services.authelia.instances.main = {
        enable = true;
        user = "authelia";
        group = "authelia";
    };*/
}
