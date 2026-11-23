{ ... }: {
  flake.nixosModules.firewall = { ... }: {
    networking.firewall.enable = true;
  };
}
