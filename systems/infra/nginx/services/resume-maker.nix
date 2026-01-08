{ daxlib, ... }:
let
    hosts = daxlib.hosts;
    preflight = import ../preflight.nix;
in
{
    services.nginx.virtualHosts = {
        "resume.dax.gay" = {
            useACMEHost = "any.dax.gay";
            forceSSL = true;
            locations."/" = {
                proxyPass = "http://${hosts.ip "services-resume"}:3000";
                proxyWebsockets = true;
                extraConfig = preflight;
            };
            locations."/minio" = {
                proxyPass = "http://${hosts.ip "services-resume"}:9000/default";
                proxyWebsockets = true;
                extraConfig = preflight;
            };
        };
    };
}
