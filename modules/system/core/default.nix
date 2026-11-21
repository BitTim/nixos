{ self, ... }: {
  flake.nixosModules.core =
    { ... }:
    let
      modules = with self.nixosModules; [
        user
        nix
      ];
    in
    {
      imports = modules;

      system.stateVersion = "26.05";
    };
}
