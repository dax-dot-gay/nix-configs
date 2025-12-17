{ ... }:
{
    boot.supportedFilesystems = [ "nfs" ];
    fileSystems."/shared" = {
        device = "infra-nfs.lsb:/shared";
        fsType = "nfs";
        options = [ "x-systemd.automount" "noauto" ];
    };
}
