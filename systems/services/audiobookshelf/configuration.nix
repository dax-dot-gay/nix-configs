{ ... }:
{
    services.audiobookshelf = {
        enable = true;
        host = "0.0.0.0";
        port = 8000;
        openFirewall = true;
        user = "root";
        group = "root";
    };
    ensurePaths.folders."/shared/data/media/Audiobooks" = { };
    ensurePaths.folders."/shared/data/media/Podcasts" = {};
}
