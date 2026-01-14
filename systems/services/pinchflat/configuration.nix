{ ... }:
{
    lesbos.volumes = {
        "/vol/music" = {
            path = "data/media/Music";
        };
        "/vol/pinchflat" = {
            path = "systems/services/pinchflat";
        };
    };
    virtualisation.oci-containers.containers."pinchflat" = {
        image = "ghcr.io/kieraneglin/pinchflat:latest";
        environment = {
            TZ = "America/New_York";
            JOURNAL_MODE = "delete";
            ENABLE_PROMETHEUS = "true";
        };
        volumes = [
            "/vol/pinchflat:/config"
            "/vol/music:/downloads"
        ];
        user = "root:root";
        ports = [ "0.0.0.0:8945:8945" ];
    };
}
