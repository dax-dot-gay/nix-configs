{ ... }:
{
    secrets.secrets."authelia/config.yaml" = {
        sopsFile = ../../../secrets/authelia.yaml;
        format = "binary";
        hosts = [ "infra-authelia" ];
    };
    ensurePaths.folders."/shared/systems/infra/authelia" = { };

}
