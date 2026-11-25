{ ... }: {
  flake.nixosModules.seerr = { ... }: {
    services.seerr.enable = true;

    # Reverse Proxy Setup
    my.proxy.owl.port = 5055;
  };
}
