{ pkgs, ... }:
let
    cinny_config = (pkgs.formats.json { }).generate "config.json" {
        defaultHomeserver = 0;
        homeserverList = [
            "dax.gay"
            "matrix.org"
            "mozilla.org"
        ];
        allowCustomHomeservers = true;
        featuredCommunities = {
            openAsDefault = false;
            servers = [ "dax.gay" ];
            spaces = [ "#cat-tower:dax.gay" ];
            rooms = [
                "#status:dax.gay"
                "#cat-tower-general-room:dax.gay"
            ];
        };
        hashRouter = {
            enabled = false;
            basename = "/";
        };
    };
in
{
    virtualisation.oci-containers.containers.cinny = {
        image = "ajbura/cinny:latest";
        ports = [ "0.0.0.0:9081:80" ];
        volumes = [ "${cinny_config}:/app/config.json" ];
        autoStart = true;
    };
}
