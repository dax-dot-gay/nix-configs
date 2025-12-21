{ ... }:
{
    ensurePaths.folders."/shared/systems/services/wizarr" = { owner = "wizarr"; group = "wizarr"; mode = "660"; };
    virtualisation.oci-containers.containers.wizarr = {
        autoStart = true;
        image = "ghcr.io/wizarrrr/wizarr";
        ports = [ "0.0.0.0:5690:5690" ];
        volumes = [ "/shared/systems/services/wizarr:/data" ];
        environment = {
            DISABLE_BUILTIN_AUTH = "false";
            TZ = "America/New_York";
        };
        user = "wizarr:wizarr";
    };
    networking.firewall.allowedTCPPorts = [ 5690 ];
}
