{ self, ... }: {
  flake.nixosModules.core =
    { ... }:
    let
      modules = with self.nixosModules; [
        user
        nix
        ssh
      ];
    in
    {
      imports = modules;

      system.stateVersion = "26.05";
    };
}
