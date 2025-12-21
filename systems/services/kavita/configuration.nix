{ config, ... }:
{
    ensurePaths.folders."/shared/systems/services/kavita" = {
        owner = "kavita";
        group = "kavita";
        mode = "660";
    };
    secrets.secrets."kavita_key".owner = "kavita";
    services.kavita = {
        enable = true;
        user = "kavita";
        dataDir = "/shared/systems/services/kavita";
        tokenKeyFile = config.sops.secrets."kavita_key".path;
        port = 5000;
        ipAdresses = [ "0.0.0.0" ];
    };
    networking.firewall.allowedTCPPorts = [5000];
}
