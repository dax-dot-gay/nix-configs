{ ... }:
{
    boot.supportedFilesystems = [ "nfs" ];
    fileSystems."/shared" = {
        device = "infra-nfs.lsb:/shared";
        fsType = "nfs";
        options = [ "nfsvers=4.2" "x-systemd.automount" "noauto" ];
    };
}
