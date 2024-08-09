{ modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/profiles/qemu-guest.nix")
    ];

  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  disko.enableConfig = true;
  disko.devices = {
    #nodev = {
    #  "/" = {
    #    fsType = "tmpfs";
    #    mountOptions = [ "defaults" "size=50%" "mode=755" ];
    #  };
    #};
    disk.vda = {
      imageSize = "3G";
      #device = "/dev/vda";
      device = "/dev/sda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            size = "1M";
            type = "EF02"; # for grub MBR
            priority = 0; # highest priority so space will be at the start of the disk
          };

          ESP = {
            label = "BOOT";
            size = "300M";
            type = "EF00";
            priority = 1;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["fmask=0077" "dmask=0077"];
            };
          };

          root = {
            label = "NIXOS";
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

  # grow/autoResize does not work with nix's impersistence
  # and requires ext3/4
  boot.growPartition = true;
  fileSystems."/".autoResize = true;
}
