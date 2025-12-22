{ pkgs, lib, ... }:

{
    services.nfs.server = {
        enable = true;
        exports = ''
            /export 192.168.30.0/24(anonuid=0,anongid=0,rw,insecure,async,fsid=0,no_subtree_check,all_squash,no_root_squash) 10.1.8.0/24(anonuid=0,anongid=0,rw,insecure,async,fsid=0,no_subtree_check,all_squash,no_root_squash)
            /export/shared 192.168.30.0/24(anonuid=0,anongid=0,rw,insecure,async,no_subtree_check,all_squash,no_root_squash) 10.1.8.0/24(anonuid=0,anongid=0,rw,insecure,async,no_subtree_check,all_squash,no_root_squash) 
        '';
    };

    ensurePaths.folders = {
        "/export" = {owner = "root"; group = "root"; mode = "777";};
        "/export/shared" = {owner = "root"; group = "root"; mode = "777";};
    };

    services.nfs.idmapd.settings = {
        Mapping = {
            Nobody-Group = lib.mkForce "root";
            Nobody-User = lib.mkForce "root";
        };
    };

    networking.firewall.enable = false;

    environment.systemPackages = [ pkgs.rclone ];
}
