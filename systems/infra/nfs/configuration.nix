{ pkgs, config, ... }:
let 
    nfs_uid = builtins.toString config.users.users.nfsuser.uid;
    nfs_gid = builtins.toString config.users.groups.nfsuser.gid;
in
{
    services.nfs.server = {
        enable = true;
        exports = ''
            /export 192.168.30.0/24(all_squash,anonuid=${nfs_uid},anongid=${nfs_gid},rw,insecure,async,fsid=0,no_subtree_check) 10.1.8.0/24(all_squash,anonuid=${nfs_uid},anongid=${nfs_gid},rw,insecure,async,fsid=0,no_subtree_check)
            /export/shared 192.168.30.0/24(all_squash,anonuid=${nfs_uid},anongid=${nfs_gid},rw,insecure,async,no_subtree_check) 10.1.8.0/24(all_squash,anonuid=${nfs_uid},anongid=${nfs_gid},rw,insecure,async,no_subtree_check)
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
