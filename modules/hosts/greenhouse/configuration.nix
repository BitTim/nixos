{ ... }: {
  flake.nixosModules.greenhouseConfiguration = { pkgs, ... }: {
    imports = [ ./_hardware-configuration.nix ];

    networking.hostName = "greenhouse";

    # LUKS drive encryption setup
    boot.initrd.systemd.enable = true;
    security.tpm2.enable = true;

    # Root
    boot.initrd.luks.devices."luks-7447c187-d660-47dd-853e-e6ca3415225d" = {
      device = "/dev/disk/by-uuid/7447c187-d660-47dd-853e-e6ca3415225d";
      crypttabExtraOpts = [ "tpm2-device=auto" ];
    };

    # Swap
    boot.initrd.luks.devices."luks-10037492-ff7c-481f-b9cc-a1e877fabea8" = {
      device = "/dev/disk/by-uuid/10037492-ff7c-481f-b9cc-a1e877fabea8";
      crypttabExtraOpts = [ "tpm2-device=auto" ];
    };
  };
}
