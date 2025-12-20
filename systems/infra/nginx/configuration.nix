{ config, daxlib, ... }:
let
    hosts = daxlib.hosts;
    preflight = import ./preflight.nix;
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
    imports = [
        ./services
    ];
    security.acme = {
        acceptTerms = true;
        defaults = {
            email = "me@dax.gay";
            environmentFile = "${config.sops.secrets.acme.path}";
            dnsProvider = "namecheap";
        };

        certs = {
            "dax.gay" = {
                domain = "dax.gay";
                group = config.services.nginx.group;
            };
            "any.dax.gay" = {
                domain = "*.dax.gay";
                group = config.services.nginx.group;
            };
            "any.matrix.dax.gay" = {
                domain = "*.matrix.dax.gay";
                group = config.services.nginx.group;
            };
        };
    };
    networking.firewall.enable = false;

    services.nginx = {
        enable = true;
        recommendedProxySettings = true;
        recommendedTlsSettings = true;
        recommendedGzipSettings = true;
        recommendedOptimisation = true;

        sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

        appendHttpConfig = ''
            # Add HSTS header with preloading to HTTPS requests.
            # Adding this header to HTTP requests is discouraged
            map $scheme $hsts_header {
                https   "max-age=31536000; includeSubdomains; preload";
            }
            add_header Strict-Transport-Security $hsts_header;

            proxy_hide_header Access-Control-Allow-Origin;
            proxy_set_header X-Forwarded-For $remote_addr;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Host $host;

            map $http_origin $allowed_origin {
                default "";  # Block invalid origins
                ~^(https?):\/\/([a-zA-Z0-9-]+\.)*dax\.gay(:\d+)?$ $http_origin;  # Allow valid origins
            }

            add_header 'Access-Control-Allow-Origin' '*' always;
        '';

        virtualHosts = {
            "fs.dax.gay" = mkHost {
                hostname = "services-access";
                port = 8080;
            };
            "retro.dax.gay" = mkHost {
                hostname = "services-romm";
                port = 8080;
            };
            "ebooks.dax.gay" = mkHost {
                hostname = "services-kavita";
                port = 5000;
            };
            "audiobooks.dax.gay" = mkHost {
                hostname = "services-audiobookshelf";
                port = 8000;
            };
            "invite.dax.gay" = mkHost {
                hostname = "services-wizarr";
                port = 5690;
            };
            "dax.gay" = {
                useACMEHost = "dax.gay";
                forceSSL = true;
                locations = {
                    "/.well-known/openid-configuration" = {
                        proxyPass = "http://${hosts.ip "services-matrix"}:8085/.well-known/openid-configuration";
                        proxyWebsockets = true;
                        extraConfig = preflight;
                    };
                    "/.well-known/matrix/client" = {
                        return = ''
                            200 '{
                                "m.homeserver": {
                                    "base_url": "https://matrix.dax.gay"
                                },
                                "m.identity_server": {
                                    "base_url": "https://vector.im"
                                },
                                "org.matrix.msc3575.proxy": {
                                    "url": "https://matrix.dax.gay"
                                },
                                "org.matrix.msc4143.rtc_foci": [
                                    {
                                    "type": "livekit",    "livekit_service_url": "https://livekit.matrix.dax.gay"
                                    }
                                ]
                            }'
                        '';
                        extraConfig = ''
                            default_type application/json;
                        ''
                        + preflight;
                    };
                    "/.well-known/matrix/server" = {
                        return = ''
                            200 '{"m.server":"matrix.dax.gay:443"}'
                        '';
                        extraConfig = ''
                            default_type application/json;
                        ''
                        + preflight;
                    };
                };
            };
        };
    };
}
