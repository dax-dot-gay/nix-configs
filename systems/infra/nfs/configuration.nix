{ pkgs, ... }:
{
    services.nfs.server = {
        enable = true;
        exports = ''
            /shared 192.168.30.0/24(no_root_squash,rw,insecure,async,fsid=0,no_subtree_check) 10.1.8.0/24(no_root_squash,rw,insecure,async,fsid=0,no_subtree_check)
        '';
    };

    networking.firewall.enable = false;

    environment.systemPackages = [ pkgs.rclone ];
}
