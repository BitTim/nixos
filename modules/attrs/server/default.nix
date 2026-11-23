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
        starship
        sops
        domain
      ];
    in
    {
      imports = modules;
    }
  );
}
