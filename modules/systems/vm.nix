{ disko, modulesPath, lib, ... }:
{
    imports = [
        (modulesPath + "/profiles/qemu-guest.nix")
    ];

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

    boot.loader.systemd-boot = {
        enable = true;
    };

    boot.loader.efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/EFI";
    };

    boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
    boot.initrd.kernelModules = [];
    boot.kernelModules = ["kvm-intel"];
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
