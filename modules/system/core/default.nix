{ self, ... }: {
  flake.nixosModules.core =
    { ... }:
    let
      modules = with self.nixosModules; [
        user
        locale
        nix
        ssh
      ];
    in
    {
      imports = modules;

      system.stateVersion = "26.05";
    };
}
