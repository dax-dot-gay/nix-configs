{ config, ... }:
{
    /*services.jellarr = {
        enable = true;
        bootstrap = {
            enable = true;
            apiKeyFile = config.sops.secrets."jellyfin/jellarr_key";
            jellyfinDataDir = "/shared/systems/services/jellyfin";
        };
        config = {
            base_url = "http://0.0.0.0:8096";
            
        };
    };*/

    hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_535;
    hardware.nvidia.enabled = true;
}
