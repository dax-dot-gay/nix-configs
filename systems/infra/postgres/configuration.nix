{
    config,
    daxlib,
    pkgs,
    ...
}:
let
    hosts = daxlib.hosts;
in
{
    ensurePaths.folders."/shared/systems/infra/postgres" = { };
    ensurePaths.folders."/shared/systems/infra/pgadmin" = { };
    secrets.secrets = {
        "pgadmin/password" = { };
    };
    networking.firewall.allowedTCPPorts = [ 5432 ];
    services.postgresql = {
        enable = true;
        package = pkgs.postgresql_17;
        dataDir = "/shared/systems/infra/postgres";
        identMap = ''
            superuser_map   root        postgres
            superuser_map   postgres    postgres
            superuser_map   /^(.*)$     \1
        '';
        authentication = ''
            #type   database    DBuser  auth-method
            local   all         all     trust
            host    sameuser    all     127.0.0.1/32 scram-sha-256
            host    sameuser    all     ::1/128 scram-sha-256
            host    sameuser    all     192.168.30.0/24 scram-sha-256
            host    sameuser    all     10.1.8.0/24 scram-sha-256
        '';
        enableTCPIP = true;
        port = 5432;
        ensureUsers = [
            {
                name = "nextcloud";
                ensureDBOwnership = true;
                ensureClauses = {
                    login = true;
                    password = "SCRAM-SHA-256$4096:MGAd0pYiR7cgXLfEqVeaTw==$9jf2mIYgve8DjhO2SSV2+BAss7Gm0OyyvW7xX4Vnmt0=:zxstJYKlG4LNpbKmVyB2xXbvDbkIsBkhE68shr9G46s=";
                };
            }
            {
                name = "pgadmin";
                ensureDBOwnership = true;
                ensureClauses = {
                    login = true;
                    password = "SCRAM-SHA-256$4096:Sbi3PQwwe/0qHsd2QYj6YA==$ZBvUziT3EkQREAcKBWUAAPWh1pvykCbuMF+d12/U/P8=:TSk68faPT6VPAZ4Tfci/2bnYjIdKbzyKXJmDzYNz/0U=";
                    superuser = true;
                };
            }
        ];
        ensureDatabases = ["nextcloud" "pgadmin"];
    };

    services.pgadmin = {
        enable = true;
        port = 5050;
        openFirewall = true;
        initialEmail = "me@dax.gay";
        initialPasswordFile = config.sops.secrets."pgadmin/password".path;
        settings.SQLITE_PATH = "/shared/systems/infra/pgadmin/pgadmin.db";
    };
}
