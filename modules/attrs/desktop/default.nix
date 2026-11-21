{ moduleWithSystem, self, ... }: {
  flake.nixosModules.desktop = moduleWithSystem (
    { pkgs, ... }:
    let
      modules = with self.nixosModules; [
        core
        bootloader-grub
        networking
        zsh
      ];
    in
    {
      imports = modules;
    }
  );
}
