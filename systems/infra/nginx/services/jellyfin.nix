{ daxlib, ... }:
let
    hosts = daxlib.hosts;
    preflight = import ../preflight.nix;
in
{
    services.nginx.virtualHosts = {
        "jellyfin.dax.gay" = {
            useACMEHost = "any.dax.gay";
            forceSSL = true;
            locations."/" = {
                proxyPass = "http://${hosts.ip "services-jellyfin"}:8096";
                proxyWebsockets = true;
                extraConfig = preflight;
            };
        };
    };
}
