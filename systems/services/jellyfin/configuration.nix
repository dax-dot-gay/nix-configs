{ config, pkgs, ... }:
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
    hardware.nvidia.open = false;
    hardware.nvidia.powerManagement.enable = false;

    environment.systemPackages = with pkgs; [
        libva-utils
        nvidia-vaapi-driver
    ];
}
