{ daxlib, ... }:
let
    hosts = daxlib.hosts;
    preflight = import ../preflight.nix;
in
{
    services.nginx.virtualHosts = {
        "ebooks.dax.gay" = {
            useACMEHost = "any.dax.gay";
            forceSSL = true;
            locations."/" = {
                proxyPass = "http://${hosts.ip "services-booklore"}:6060";
                proxyWebsockets = true;
                extraConfig = preflight + ''
                    proxy_set_header X-Forwarded-Port $server_port;
                '';
            };
        };
    };
}
