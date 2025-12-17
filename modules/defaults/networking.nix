{ hostname, ... }:
let
    hosts = (import ../../lib).hosts;
in
{
    networking = {
        networkmanager.enable = true;
        hosts = hosts.makeHosts hostname;
        hostName = hostname;
        interfaces = { eth0.ipv4.addresses = [ {
            address = (hosts.getHost hostname).ip;
            prefixLength = 24;
        } ]; };
    };

    time.timeZone = "America/New_York";
}
