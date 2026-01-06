{
    config,
    daxlib,
    pkgs,
    lib,
    ...
}:
let
    hosts = daxlib.hosts;
    apps = builtins.fromJSON (lib.readFile ./apps.json);
    nextcloudApps =
        names:
        lib.listToAttrs (
            lib.map (item: {
                name = item;
                value = pkgs.fetchNextcloudApp {
                    appName = item;
                    appVersion = apps."${item}".version;
                    license = builtins.elemAt apps."${item}".licenses 0;
                    sha256 = apps."${item}".hash;
                    url = apps."${item}".url;
                };
            }) names
        );
in
{
    secrets.secrets = {
        "nextcloud/admin" = { };
        "nextcloud/dbpassword" = { };
        "nextcloud/secret" = { };
    };

    ensurePaths.folders = {
        "/shared/systems/services/nextcloud/skeletons" = { };
        "/shared/systems/services/nextcloud/data" = { };
        "/shared/systems/services/nextcloud/home" = { };
    };

    services.nextcloud = {
        enable = true;
        hostName = "nextcloud.dax.gay";
        datadir = "/shared/systems/services/nextcloud/data";
        home = "/shared/systems/services/nextcloud/home";
        skeletonDirectory = "/shared/systems/services/nextcloud/skeletons";
        secrets = {
            secret = config.sops.secrets."nextcloud/secret".path;
        };
        config = {
            dbtype = "pgsql";
            dbuser = "nextcloud";
            dbname = "nextcloud";
            dbpassFile = config.sops.secrets."nextcloud/dbpassword".path;
            dbhost = "${hosts.ip "infra-database"}:5432";
            adminpassFile = config.sops.secrets."nextcloud/admin".path;
            adminuser = "admin";
        };
        configureRedis = true;
        caching.redis = true;
        caching.apcu = false;
        settings.overwriteprotocol = "https";
        package = pkgs.nextcloud32;
        extraAppsEnable = true;
        extraApps = {
            inherit (pkgs.nextcloud32Packages.apps)
                news
                calendar
                contacts
                tasks
                polls
                bookmarks
                mail
                deck
                notes
                ;
        }
        // (nextcloudApps [
            "forms"
            "music"
            "secrets"
            "iframewidget"
            "user_oidc"
            "doom_nextcloud"
            "drawio"
            "files_automatedtagging"
            "groupfolders"
            "cookbook"
            "external"
            "onlyoffice"
            "riotchat"
        ]);
    };
}
