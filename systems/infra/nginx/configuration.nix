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
                domain = "dax.gay";
            };
            "any.dax.gay" = {
                group = "nginx";
                domain = "*.dax.gay";
            };
            "any.matrix.dax.gay" = {
                group = "nginx";
                domain = "*.matrix.dax.gay";
            };
        };
    };
}
