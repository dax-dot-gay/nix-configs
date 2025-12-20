{ ... }:
{
    ensurePaths.folders."/shared/systems/services/wizarr" = { };
    virtualisation.oci-containers.containers.wizarr = {
        autoStart = true;
        image = "ghcr.io/wizarrrr/wizarr";
        ports = [ "0.0.0.0:5690:5690" ];
        volumes = [ "/shared/systems/services/wizarr:/data" ];
        environment = {
            DISABLE_BUILTIN_AUTH = "false";
            TZ = "America/New_York";
            PUID = "568";
            PGID = "568";
        };
        user = "wizarr:wizarr";
    };
    users.groups.wizarr.gid = 568;
    users.users.wizarr = {
        isSystemUser = true;
        uid = 568;
        group = "wizarr";
    };
    networking.firewall.allowedTCPPorts = [ 5690 ];
}
