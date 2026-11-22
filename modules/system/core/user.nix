{ moduleWithSystem, ... }: {
  flake.nixosModules.user = moduleWithSystem (
    { self', ... }: {
      users.users = {
        lea = {
          isNormalUser = true;
          initialPassword = "password";
          shell = self'.packages.zsh;
          description = "Lea Anhalt";
          extraGroups = [
            "root"
            "wheel"
          ];
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPgs7XcyM955HeXFHc87jCGzhZbuxsZpxg0QsIWDaoqm orchid"
            "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBrm11sS8KEXo3QY6LsmGKjMyIETDeKFcECbmkpiRh3tvWoio0Gf55kDX0yenYtAYg1+0bbHeaJZQ4LtndabvCU="
          ];
        };
      };
    }
  );
}
