{ moduleWithSystem, inputs, ... }: {
  flake.nixosModules.starship = moduleWithSystem (
    { self', ... }: {
      programs.starship = {
        enable = true;
        package = self'.packages.starship;
      };
    }
  );

  perSystem = { pkgs, ... }: {
    packages.starship = inputs.wrappers.wrappers.starship.wrap {
      inherit pkgs;
      preset = [ "pastel-powerline" ];
    };
  };
}
