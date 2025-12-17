{ config, ... }:
{
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
            };
            "any.dax.gay" = {
                domain = "*.dax.gay";
            };
            "any.matrix.dax.gay" = {
                domain = "*.matrix.dax.gay";
            };
        };
    };
}
