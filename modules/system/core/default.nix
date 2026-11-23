{ self, ... }: {
  flake.nixosModules.core =
    { ... }:
    let
      modules = with self.nixosModules; [
        user
        locale
        nix
        ssh
        firewall
      ];
    in
    {
      imports = modules;

      system.stateVersion = "26.05";
    };
}
