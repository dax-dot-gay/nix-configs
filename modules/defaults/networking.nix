{ hostname, daxlib, ... }:
let
    hosts = daxlib.hosts;
in
{
    networking = {
        networkmanager.enable = true;
        hosts = hosts.makeHosts hostname;
        hostName = hostname;
    };

    time.timeZone = "America/New_York";
}
