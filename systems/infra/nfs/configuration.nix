{ pkgs, config, lib, daxlib, ... }:
let
    nfsuser = toString config.users.users.nfsuser.uid;
    nfsgroup = toString config.users.groups.nfsuser.gid;
    hosts = daxlib.hosts;
in
{
    services.nfs.server = {
        enable = true;
        exports = ''
            /export 192.168.30.0/24(anonuid=${nfsuser},anongid=${nfsgroup},rw,insecure,async,fsid=0,no_subtree_check,root_squash,no_all_squash,crossmnt) ${hosts.ip "services-wizarr"}(anonuid=${nfsuser},anongid=${nfsgroup},rw,insecure,async,fsid=0,no_subtree_check,no_root_squash,no_all_squash,crossmnt) 
            /export/shared 192.168.30.0/24(anonuid=${nfsuser},anongid=${nfsgroup},rw,insecure,async,no_subtree_check,root_squash,no_all_squash,crossmnt) ${hosts.ip "services-wizarr"}(anonuid=${nfsuser},anongid=${nfsgroup},rw,insecure,async,no_subtree_check,no_root_squash,no_all_squash,crossmnt)
        '';
    };

    ensurePaths.folders = {
        "/export" = {owner = "nfsuser"; group = "nfsuser"; mode = "777";};
        "/export/shared" = {owner = "nfsuser"; group = "nfsuser"; mode = "777";};
    };

    services.nfs.idmapd.settings = {
        Mapping = {
            Nobody-Group = lib.mkForce "nfsuser";
            Nobody-User = lib.mkForce "nfsuser";
        };
    };

    networking.firewall.enable = false;

    environment.systemPackages = [ pkgs.rclone ];
}
