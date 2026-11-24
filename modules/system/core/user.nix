{ moduleWithSystem, lib, ... }: {
  flake.nixosModules.user = moduleWithSystem (
    { self', ... }: { config, ... }: {
      options.my = {
        user = {
          name = lib.mkOption {
            type = lib.types.str;
            default = "lea";
          };
          description = lib.mkOption {
            type = lib.types.str;
            default = "Lea Anhalt";
          };
        };
      };

      config = {
        sops.secrets.user-password.neededForUsers = true;
        users.users = {
          ${config.my.user.name} = {
            isNormalUser = true;
            hashedPasswordFile = config.sops.secrets.user-password.path;
            shell = self'.packages.zsh;
            description = config.my.user.description;
            extraGroups = [
              "root"
              "wheel"
            ];
            openssh.authorizedKeys.keys = [
              # MacBook
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPgs7XcyM955HeXFHc87jCGzhZbuxsZpxg0QsIWDaoqm orchid"

              # Termius (iOS)
              "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBrm11sS8KEXo3QY6LsmGKjMyIETDeKFcECbmkpiRh3tvWoio0Gf55kDX0yenYtAYg1+0bbHeaJZQ4LtndabvCU="
            ];
          };
        };
      };
    }
  );
}
