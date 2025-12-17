{ ... }:
let
    hosts = (import ../lib).hosts;
in
{
    boot.supportedFilesystems = [ "nfs" ];
    fileSystems."/shared" = {
        device = "${(hosts.getHost "infra-nfs").ip}:/export/shared";
        fsType = "nfs";
        options = [
            "nfsvers=4.2"
            "rw"
            "intr"
            "hard"
            "timeo=14"
        ];
    };
}
