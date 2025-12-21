{ ... }:
{
    ensurePaths.folders."/shared/systems/services/wizarr" = { owner = "itec"; group = "itec"; mode = "777"; };
    virtualisation.oci-containers.containers.wizarr = {
        autoStart = true;
        image = "ghcr.io/wizarrrr/wizarr";
        ports = [ "0.0.0.0:5690:5690" ];
        volumes = [ "/shared/systems/services/wizarr:/data" ];
        environment = {
            DISABLE_BUILTIN_AUTH = "false";
            TZ = "America/New_York";
            PGID = "1000";
            PUID = "1000";
        };
    };
    networking.firewall.allowedTCPPorts = [ 5690 ];
}
