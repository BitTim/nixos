{ ... }: {
  flake.nixosModules.bootloader-grub = { pkgs, ... }: {
    boot = {
      loader = {
        timeout = 2;
        efi = {
          canTouchEfiVariables = true;
        };
        grub = {
          efiSupport = true;
          device = "nodev";
        };
      };
      kernelPackages = pkgs.linuxPackages_latest;
    };
  };
}
