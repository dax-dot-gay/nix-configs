{
    config,
    pkgs,
    ...
}:
{
    ensurePaths.folders."/shared/systems/infra/postgres" = { };
    ensurePaths.folders."/shared/systems/infra/pgadmin" = { };
    ensurePaths.folders."/persistent/postgres" = {
        owner = "postgres";
        group = "postgres";
        mode = "777";
    };
    secrets.secrets = {
        "pgadmin/password" = { };
    };
    environment.systemPackages = [ pkgs.rclone ];
    networking.firewall.allowedTCPPorts = [ 5432 ];
    services.postgresql = {
        enable = true;
        package = pkgs.postgresql_17;
        dataDir = "/persistent/postgres";
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
        initialScript = pkgs.writeText "init-sql-script" ''
            ALTER ROLE pgadmin WITH PASSWORD 'SCRAM-SHA-256$4096:Sbi3PQwwe/0qHsd2QYj6YA==$ZBvUziT3EkQREAcKBWUAAPWh1pvykCbuMF+d12/U/P8=:TSk68faPT6VPAZ4Tfci/2bnYjIdKbzyKXJmDzYNz/0U=';
        '';
        ensureUsers = [
            {
                name = "pgadmin";
                ensureDBOwnership = true;
                ensureClauses = {
                    login = true;
                    superuser = true;
                };
            }
        ];
        ensureDatabases = [ "pgadmin" ];
    };

    services.pgadmin = {
        enable = true;
        port = 5050;
        openFirewall = true;
        initialEmail = "me@dax.gay";
        initialPasswordFile = config.sops.secrets."pgadmin/password".path;
        settings.SQLITE_PATH = "/shared/systems/infra/pgadmin/pgadmin.db";
    };

    systemd.services.pgadmin.serviceConfig = {
        ReadWritePaths = [ "/shared/systems/infra/pgadmin/" ];
    };
}
