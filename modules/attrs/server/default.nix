{ moduleWithSystem, self, ... }: {
  flake.nixosModules.server = moduleWithSystem (
    { pkgs, ... }:
    let
      modules = with self.nixosModules; [
        core
        bootloader-systemd
        networking
        zsh
      ];
    in
    {
      imports = modules;
    }
  );
}
