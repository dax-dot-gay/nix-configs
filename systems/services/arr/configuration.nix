{ ... }:
{
    imports = [
        ./docker-compose.nix
    ];

    secrets.secrets."arr/gluetun.env" = {
        mode = "0777";
    };

    ensurePaths.folders = {
        "/shared/data/media/Shows" = { };
        "/shared/data/media/Movies" = { };
        "/shared/systems/services/arr/audiobookrequest" = { };
        "/shared/systems/services/arr/deluge/config" = { };
        "/shared/systems/services/arr/deluge/downloads" = { };
        "/shared/systems/services/arr/jellyseerr" = { };
        "/shared/systems/services/arr/prowlarr" = { };
        "/shared/systems/services/arr/radarr" = { };
        "/shared/systems/services/arr/sonarr" = { };
    };

    networking.firewall.enable = false;
}
