{ daxlib, ... }:
let
    hosts = daxlib.hosts;
    preflight = import ../preflight.nix;
in
{
    services.nginx.virtualHosts."auth.dax.gay" = {
        useACMEHost = "any.dax.gay";
        forceSSL = true;
        locations."/" = {
            proxyPass = "http://${hosts.ip "infra-authentik"}:9000";
            proxyWebsockets = true;
        };
    };
}
