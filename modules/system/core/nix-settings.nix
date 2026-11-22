{ inputs, ... }: {
  perSystem = { system, ... }: {
    _module.args = {
      unstablePkgs = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
      unfreePkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    };
  };

  flake.nixosModules.nix = { lib, ... }: {
    nix = {
      settings.experimental-features = lib.mkDefault [
        "nix-command"
        "flakes"
      ];
      nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
      optimise.automatic = true;
      gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 5d";
      };
    };
    nixpkgs.config.allowUnfree = true;
  };
}
