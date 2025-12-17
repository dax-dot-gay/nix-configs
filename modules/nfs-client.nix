{ ... }:
{
    boot.supportedFilesystems = [ "nfs" ];
    systemd.mounts = [
        {
            type = "nfs";
            mountConfig = {
                Options = "noatime";
            };
            what = "infra-nfs.lsb:/shared";
            where = "/shared";
        }
    ];

    systemd.automounts = [
        {
            wantedBy = [ "multi-user.target" ];
            automountConfig = {};
            where = "/shared";
        }
    ];
}
