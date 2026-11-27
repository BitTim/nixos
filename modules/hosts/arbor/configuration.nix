{ ... }: {
  flake.nixosModules.arborConfiguration = { pkgs, config, ... }: {
    imports = [ ./_hardware-configuration.nix ];

    networking.hostName = "arbor";
    my.domain = "undefbloom.com";

    # Setup SOPS to point to the actual file
    sops.defaultSopsFile = ../../../secrets/arbor.yaml;

    # Configure Caddy
    my.caddy.acmeEmail = "lea@anhalt.me";

    my.caddy-portal.proxies = {
      firefly = "greenhouse:80";
      owl = "greenhouse:80";
      bee = "greenhouse:80";
      magpie = "greenhouse:80";
    };

    my.caddy-portal.tempRedirects = {
      "${config.my.domain}" = "https://lnk.bio/undefbloom";
      "www.${config.my.domain}" = "https://lnk.bio/undefbloom";

      # Legacy redirects
      "bittim.dev" = "https://linktr.ee/bittim";
      "www.bittim.dev" = "https://linktr.ee/bittim";
    };

    # Configure forwards
    my.portal-forward.forwards.minecraft = {
      port = 25565;
      to = "100.92.151.69:25565";
    };
  };
}
