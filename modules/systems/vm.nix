{ disko, ... }:
{
    disko.devices = {
        disk = {
            sda = {
                device = "/dev/sda";
                type = "disk";
                content = {
                    type = "gpt";
                    partitions = {
                        ESP = {
                            type = "EF00";
                            size = "1G";
                            content = {
                                type = "filesystem";
                                format = "vfat";
                                mountpoint = "/boot";
                                mountOptions = [ "unasm=0077" ];
                            };
                        };
                        root = {
                            size = "100%";
                            content = {
                                type = "filesystem";
                                format = "ext4";
                                mountpoint = "/";
                            };
                        };
                    };
                };
            };
        };
    };

    boot.loader.efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/EFI";
    };
}
