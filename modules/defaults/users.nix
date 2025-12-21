{ config, ... }:
{
    users.users = {
        itec = {
            isNormalUser = true;
            hashedPasswordFile = config.sops.secrets.password.path;
            group = "itec";
            uid = 1000;
            extraGroups = [ "wheel" "nfsuser" ];
        };
        root = {
            hashedPasswordFile = config.sops.secrets.password.path;
            group = "root";
            uid = 0;
        };
        nfsuser = {
            isSystemUser = true;
            uid = 200;
            group = "nfsuser";
        };
    };

    users.mutableUsers = false;

    users.groups.itec = {
        name = "itec";
        gid = 1000;
    };
    users.groups.nfsuser = {
        name = "nfsuser";
        gid = 200;
    };
}
