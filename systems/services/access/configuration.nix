{ config, ... }:
{
    services.filebrowser = {
        enable = true;
        user = "root";
        group = "root";
        openFirewall = true;
        settings = {
            root = "/shared";
            database = "/shared/systems/services/access/filebrowser.db";
            address = "0.0.0.0";
            port = 8080;
            username = config.sops.placeholder."services/access/filebrowser/username";
            password = config.sops.placeholder."services/access/filebrowser/password";
        };
    };
}
