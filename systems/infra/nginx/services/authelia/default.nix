{ daxlib, ... }:
let
    hosts = daxlib.hosts;
    proxyConfig = import ./proxy.nix;
    extraConfig = extras: extras + proxyConfig;
in
{
    services.nginx.virtualHosts."auth.dax.gay" = {
        useACMEHost = "any.dax.gay";
        forceSSL = true;
        locations."/" = {
            proxyPass = "http://${hosts.ip "infra-authelia"}:9091";
            proxyWebsockets = true;
            extraConfig = proxyConfig;
        };
    };
}
