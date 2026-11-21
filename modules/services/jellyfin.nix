{ moduleWithSystem, ... }: {
  flake.nixosModules.jellyfin = moduleWithSystem ({ ... }: { });

  perSystem = { pkgs, ... }: {

  };
}
