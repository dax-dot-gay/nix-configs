{ config, daxlib, ... }:
let
    hosts = daxlib.hosts;
    preflight = import ../preflight.nix;
    mkHost =
        {
            acmeHost ? "any.dax.gay",
            hostname,
            port,
        }:
        {
            useACMEHost = acmeHost;
            forceSSL = true;
            locations."/" = {
                proxyPass = "http://${hosts.ip hostname}:${builtins.toString port}";
                proxyWebsockets = true;
                extraConfig = preflight;
            };
        };
in
{
    services.nginx.virtualHosts = {
        "deluge.dax.gay" = mkHost {
            hostname = "services-arr";
            port = 8112;
        };
        "son.arr.dax.gay" = mkHost {
            acmeHost = "any.arr.dax.gay";
            hostname = "services-arr";
            port = 8989;
        };
        "rad.arr.dax.gay" = mkHost {
            acmeHost = "any.arr.dax.gay";
            hostname = "services-arr";
            port = 7878;
        };
        "prowl.arr.dax.gay" = mkHost {
            acmeHost = "any.arr.dax.gay";
            hostname = "services-arr";
            port = 9696;
        };
        "request.jellyfin.dax.gay" = mkHost {
            acmeHost = "any.jellyfin.dax.gay";
            hostname = "services-arr";
            port = 5055;
        };
        "lid.arr.dax.gay" = mkHost {
            acmeHost = "any.arr.dax.gay";
            hostname = "services-arr";
            port = 8686;
        };
        /*"request.audiobooks.dax.gay" = mkHost {
            acmeHost = "any.audiobooks.dax.gay";
            hostname = "services-arr";
            port = 5432;
        };*/
    };
}
