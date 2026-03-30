{ config, pkgs, ... }:
{
    ensurePaths.folders."/persistent/jellyfin" = {
        mode = "0777";
    };
    ensurePaths.folders."/persistent/jellyfin-data" = {
        mode = "0700";
    };
    system.activationScripts = {
        jellyfin-web = ''
            cp -R ${pkgs.jellyfin-web.outPath}/** /persistent/jellyfin
            chmod -R 777 /persistent/jellyfin
        '';
    };
    services.jellyfin = {
        enable = true;
        user = "root";
        group = "root";
        dataDir = "/persistent/jellyfin-data";
        openFirewall = true;
        package = pkgs.jellyfin;
    };

    hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_535;
    hardware.nvidia.open = false;
    hardware.nvidia.powerManagement.enable = false;
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.graphics.enable = true;

    environment.systemPackages = with pkgs; [
        libva-utils
        libva-vdpau-driver
        jellyfin
        jellyfin-ffmpeg
        jellyfin-web
        yt-dlp
        id3v2
    ];

    # Nightly reboots to kick people off and clear cache
    systemd.timers."reboot-nightly" = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
            OnCalendar = "daily America/New_York";
            Unit = "reboot-nightly.service";
        };
    };

    systemd.services."reboot-nightly" = {
        script = "shutdown -r now";
        serviceConfig = {
            Type = "oneshot";
            User = "root";
        };
    };
}
