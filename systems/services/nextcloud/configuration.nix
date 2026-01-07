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
                    license = "gpl3";
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

    sops.templates."nc.json".content = ''
        {"secret": "${config.sops.placeholder."nextcloud/secret"}"}
    '';

    services.nextcloud = {
        enable = true;
        hostName = "nextcloud.dax.gay";
        datadir = "/volumes/nextcloud/data";
        home = "/volumes/nextcloud/home";
        skeletonDirectory = "/volumes/nextcloud/skeletons";
        secretFile = config.sops.templates."nc.json".path;
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
        appstoreEnable = false;
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
    
    environment.systemPackages = [ pkgs.rclone ];
    lesbos.volumes = {
        "/volumes/nextcloud" = {
            path = "systems/services/nextcloud";
            owner = "nextcloud";
            group = "nextcloud";
            mode = "775";
            subpaths = [
                "data"
                "home"
                "skeletons"
                "config"
            ];
        };
    };
}
