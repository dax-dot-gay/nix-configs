{ pkgs, config, ... }:
{
    services.nfs.server = {
        enable = true;
        exports = ''
            /export 192.168.30.0/24(all_squash,anonuid=${config.users.users.nfsuser.uid},anongid=${config.users.groups.nfsuser.gid},rw,insecure,async,fsid=0,no_subtree_check) 10.1.8.0/24(all_squash,anonuid=${config.users.users.nfsuser.uid},anongid=${config.users.groups.nfsuser.gid},rw,insecure,async,fsid=0,no_subtree_check)
            /export/shared 192.168.30.0/24(all_squash,anonuid=${config.users.users.nfsuser.uid},anongid=${config.users.groups.nfsuser.gid},rw,insecure,async,no_subtree_check) 10.1.8.0/24(all_squash,anonuid=${config.users.users.nfsuser.uid},anongid=${config.users.groups.nfsuser.gid},rw,insecure,async,no_subtree_check)
        '';
    };

    networking.firewall.enable = false;

    environment.systemPackages = [ pkgs.rclone ];
    users.users.nfsuser = {
        group = "nfsuser";
        isSystemUser = true;
        uid = 650;
    };
    users.groups."nfsuser" = {gid = 650;};
}
