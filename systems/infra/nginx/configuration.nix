{ config, ... }:
{
    security.acme = {
        acceptTerms = true;
        defaults = {
            email = "me@dax.gay";
            environmentFile = config.sops.templates."namecheap.env".path;
            dnsProvider = "namecheap";
        };

        certs = {
            "dax.gay" = {
                group = "nginx";
            };
            "*.dax.gay" = {
                group = "nginx";
            };
        };
    };
}
