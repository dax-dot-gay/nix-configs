{ config, ... }:
{
    users.users = {
        itec = {
            isNormalUser = true;
            hashedPasswordFile = config.sops.secrets.password.path;
            group = "itec";
            uid = 1000;
            extraGroups = [ "wheel" ];
        };
        root = {
            hashedPasswordFile = config.sops.secrets.password.path;
            group = "root";
            uid = 0;
        };
    };
}
