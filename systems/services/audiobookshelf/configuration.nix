{ ... }:
{
    services.audiobookshelf = {
        enable = true;
        host = "0.0.0.0";
        port = 8000;
        openFirewall = true;
    };
    ensurePaths.folders."/shared/data/media/Audiobooks" = { };
}
