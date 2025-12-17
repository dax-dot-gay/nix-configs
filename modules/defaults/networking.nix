{ hostname, ... }:
let
    hosts = (import ../../lib).hosts;
in
{
    networking = {
        networkmanager.enable = true;
        hosts = hosts.makeHosts hostname;
        hostName = hostname;
    };

    time.timeZone = "America/New_York";
}
