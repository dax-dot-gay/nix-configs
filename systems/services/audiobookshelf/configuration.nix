{ ... }:
{
    services.audiobookshelf = {
        enable = true;
        host = "0.0.0.0";
        port = 8000;
        openFirewall = true;
        user = "nfsuser";
        group = "nfsuser";
    };
    ensurePaths.folders."/shared/data/media/Audiobooks" = { };
    ensurePaths.folders."/shared/data/media/Podcasts" = {};
}
