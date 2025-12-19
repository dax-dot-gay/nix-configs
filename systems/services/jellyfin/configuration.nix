{ config, pkgs, ... }:
{
    services.jellyfin = {
        enable = true;
        user = "root";
        group = "root";
        dataDir = "/shared/systems/services/jellyfin";
        openFirewall = true;
    };
    services.jellarr = {
        enable = true;
        user = "root";
        group = "root";
        bootstrap = {
            enable = true;
            apiKeyFile = "${config.sops.secrets."jellyfin/jellarr_key".path}";
            jellyfinDataDir = "/shared/systems/services/jellyfin";
        };
        config = {
            version = 1;
            base_url = "http://localhost:8096";
            system = {
                enableMetrics = true;
                pluginRepositories = [
                    {
                        name = "Jellyfin Official";
                        url = "https://repo.jellyfin.org/releases/plugin/manifest.json";
                        enabled = true;
                    }
                    {
                        name = "Intro Skipper";
                        url = "https://intro-skipper.org/manifest.json";
                        enabled = true;
                    }
                    {
                        name = "Jellyfin Enhanced";
                        url = "https://raw.githubusercontent.com/n00bcodr/jellyfin-plugins/main/10.11/manifest.json";
                        enabled = true;
                    }
                ];
                trickplayOptions = {
                    enableHwAcceleration = true;
                    enableHwEncoding = true;
                };
            };
            encoding = {
                enableHardwareEncoding = true;
                hardwareAccelerationType = "nvenc";
                hardwareDecodingCodecs = [
                    "h264"
                    "hevc"
                    "mpeg2video"
                    "vc1"
                    "vp8"
                    "vp9"
                ];
                enableDecodingColorDepth10Hevc = true;
                enableDecodingColorDepth10HevcRext = true;
                enableDecodingColorDepth12HevcRext = true;
                enableDecodingColorDepth10Vp9 = true;
                allowHevcEncoding = false;
                allowAv1Encoding = false;
            };
            library = {
                virtualFolders = [
                    {
                        name = "Movies";
                        collectionType = "movies";
                        libraryOptions.pathInfos = [{path = "/shared/data/media/Movies";}];
                    }
                    {
                        name = "Shows";
                        collectionType = "tvshows";
                        libraryOptions.pathInfos = [{path = "/shared/data/media/Shows";}];
                    }
                ];
            };
            users = [
                {
                    name = "itec";
                    passwordFile = config.sops.secrets."jellyfin/admin_password".path;
                    policy = {
                        isAdministrator = true;
                        loginAttemptsBeforeLockout = 3;
                    };
                }
            ];
            startup.completeStartupWizard = true;
        };
    };

    hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_535;
    hardware.nvidia.open = false;
    hardware.nvidia.powerManagement.enable = false;
    services.xserver.videoDrivers = ["nvidia"];
    hardware.graphics.enable = true;

    environment.systemPackages = with pkgs; [
        libva-utils
        libva-vdpau-driver
    ];
}
