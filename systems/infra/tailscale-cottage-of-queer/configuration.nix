{ config, ... }:
{
    secrets.secrets = {
        "tailscale-cottage-of-queer/auth_key" = { neededForUsers = true; };
    };

    services.tailscale = {
        enable = true;
        useRoutingFeatures = "server";
        openFirewall = true;
        authKeyFile = config.sops.secrets."tailscale-cottage-of-queer/auth_key".path;
        authKeyParameters.preauthorized = false;
        extraUpFlags = [ "--advertise-exit-node" ];
    };

    system.stateVersion = "25.11";
    networking = {
        networkmanager.enable = true;
        hostName = "infra-tailscale-cottage-of-queer";
    };

    time.timeZone = "America/New_York";
}
