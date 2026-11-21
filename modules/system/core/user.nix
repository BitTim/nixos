{ moduleWithSystem, ... }: {
  flake.nixosModules.user = moduleWithSystem (
    { self', ... }: {
      users.users = {
        lea = {
          isNormalUser = true;
          initialPassword = "password";
          shell = self'.packages.zsh;
          description = "Lea A";
          extraGroups = [
            "root"
            "wheel"
          ];
        };
      };
    }
  );
}
