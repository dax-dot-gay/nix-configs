{ utils, ... }:
let
    hosts = utils.hosts;
in
{
    boot.supportedFilesystems = [ "nfs" ];
    fileSystems."/shared" = {
        device = "${(hosts.getHost "infra-nfs").ip}:/shared";
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
