{ daxlib, ... }:
let
    hosts = daxlib.hosts;
in
{
    boot.supportedFilesystems = [ "nfs" ];
    fileSystems."/shared" = {
        device = "${(hosts.getHost "infra-nfs").ip}:/shared";
        fsType = "nfs";
        options = [
            "nfsvers=3"
            "rw"
            "intr"
            "hard"
            "timeo=14"
        ];
    };
}
