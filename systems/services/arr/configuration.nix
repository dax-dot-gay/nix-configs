{ ... }:
{
    imports = [
        ./docker-compose.nix
    ];

    secrets.secrets."arr/gluetun.env" = {
        mode = "0666";
    };

    ensurePaths.folders = {
        "/shared/data/media/Shows" = { };
        "/shared/data/media/Movies" = { };
        "/shared/data/media/Podcasts" = { };
        "/shared/data/media/Books" = { };
        "/shared/data/media/Audiobooks" = { };
        "/shared/data/media/Music" = { };
        "/shared/systems/services/arr/audiobookrequest" = { };
        "/shared/systems/services/arr/deluge/config" = { };
        "/shared/systems/services/arr/deluge/downloads" = { };
        "/shared/systems/services/arr/jellyseerr" = { };
        "/shared/systems/services/arr/prowlarr" = { };
        "/shared/systems/services/arr/radarr" = { };
        "/shared/systems/services/arr/sonarr" = { };
        "/shared/systems/services/arr/lidarr" = { };
        "/shared/systems/services/arr/lidatube" = {};
    };

    networking.firewall.enable = false;
}
