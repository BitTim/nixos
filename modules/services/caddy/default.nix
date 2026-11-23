{ moduleWithSystem, lib, ... }: {
  flake.nixosModules.caddy = moduleWithSystem (
    { ... }: { config, ... }: {
      options.my.caddy.acmeEmail = lib.mkOption { type = lib.types.str; };
      config.services.caddy = {
        enable = true;
        email = config.my.caddy.acmeEmail;
      };
    }
  );
}
