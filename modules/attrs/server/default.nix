{ moduleWithSystem, self, ... }: {
  flake.nixosModules.server = moduleWithSystem (
    { pkgs, ... }:
    let
      modules = with self.nixosModules; [
        core
        bootloader-systemd
        zsh
        git
        tailscale
        hyfetch
      ];
    in
    {
      imports = modules;
    }
  );
}
