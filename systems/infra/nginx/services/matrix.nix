{ daxlib, ... }:
let
    hosts = daxlib.hosts;
    preflight = import ../preflight.nix;
in
{
    services.nginx.virtualHosts = {
        "cinny.dax.gay" = {
            useACMEHost = "any.dax.gay";
            forceSSL = true;
            locations."/" = {
                proxyPass = "http://${hosts.ip "services-matrix"}:9081";
                proxyWebsockets = true;
                extraConfig = preflight;
            };
        };
        "auth.matrix.dax.gay" = {
            useACMEHost = "any.matrix.dax.gay";
            forceSSL = true;
            locations."/" = {
                proxyPass = "http://${hosts.ip "services-matrix"}:8085";
                proxyWebsockets = true;
                extraConfig = preflight;
            };
        };
        "livekit.matrix.dax.gay" = {
            useACMEHost = "any.matrix.dax.gay";
            forceSSL = true;
            locations = {
                "/" = {
                    proxyPass = "http://${hosts.ip "services-matrix"}:7881";
                    proxyWebsockets = true;
                };
                "/sfu/get" = {
                    proxyPass = "http://${hosts.ip "services-matrix"}:8080";
                    proxyWebsockets = true;
                };
                "/healthz" = {
                    proxyPass = "http://${hosts.ip "services-matrix"}:8080";
                    proxyWebsockets = true;
                };
            };
        };
        "matrix.dax.gay" = {
            useACMEHost = "any.dax.gay";
            forceSSL = true;
            serverName = "matrix.dax.gay";
            locations = {
                "~ ^/_matrix/client/(.*)/(login|logout|refresh)" = {
                    proxyPass = "http://${hosts.ip "services-matrix"}:8085";
                    proxyWebsockets = true;
                    extraConfig = preflight;
                };
                "/.well-known/openid-configuration" = {
                    proxyPass = "http://${hosts.ip "services-matrix"}:8085/.well-known/openid-configuration";
                    proxyWebsockets = true;
                    extraConfig = preflight;
                };
                "/" = {
                    proxyPass = "http://${hosts.ip "services-matrix"}:8008";
                    proxyWebsockets = true;
                    extraConfig = preflight;
                };
            };
        };
        "admin.matrix.dax.gay" = {
            useACMEHost = "any.matrix.dax.gay";
            forceSSL = true;
            locations."/" = {
                proxyPass = "http://${hosts.ip "services-matrix"}:9080";
                proxyWebsockets = true;
                extraConfig = preflight;
            };
        };
    };
}
