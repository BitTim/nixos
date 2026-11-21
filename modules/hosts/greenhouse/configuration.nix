{ ... }: {
  flake.nixosModules.greenhouseConfiguration = { pkgs, ... }: {
    imports = [ ./_hardware-configuration.nix ];

    networking.hostName = "greenhouse";
  };
}
