{ config, ... }:
{
    secrets.secrets = {
        "syncthing" = { };
    };

    ensurePaths.folders = {
        "/shared/systems/services/syncthing/database" = { };
        "/shared/systems/services/syncthing/data" = { };
        "/shared/systems/services/syncthing/config" = { };
    };

    networking.firewall.enable = false;

    services.syncthing = {
        enable = true;
        user = "root";
        group = "root";
        guiAddress = "0.0.0.0:8384";
        guiPasswordFile = config.sops.syncthing.path;
        databaseDir = "/shared/systems/services/syncthing/database";
        dataDir = "/shared/systems/services/syncthing/data";
        configDir = "/shared/systems/services/syncthing/config";
    };
}
