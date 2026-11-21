{ moduleWithSystem, inputs, ... }: {
  flake.nixosModules.starship = moduleWithSystem (
    { self', ... }: {
      environment.systemPackages = [ self'.packages.starship ];
    }
  );

  perSystem = { pkgs, ... }: {
    packages.starship = inputs.wrappers.wrappers.starship.wrap {
      inherit pkgs;
      preset = [ "pastel-powerline" ];
    };
  };
}
