{ moduleWithSystem, lib, ... }: {
  flake.nixosModules.domain = moduleWithSystem (
    { ... }: {
      options.my.domain = lib.mkOption {
        type = lib.types.str;
        description = "Base domain for all services";
      };
    }
  );
}
