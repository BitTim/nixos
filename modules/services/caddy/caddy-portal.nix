{ self, ... }:
{
  flake.nixosModules.caddy-portal =
    { config, lib, ... }:
    let
      cfg = config.my.caddy-portal;
      domain = config.my.domain;
    in
    {
      imports = [ self.nixosModules.caddy ];

      options.my.caddy-portal = {
        proxies = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
          description = "subdomain -> upstream (host:port)";
        };
        tempRedirects = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
          description = "source hostname -> target URL (temporary)";
        };
      };

      config = {
        services.caddy.virtualHosts =
          (lib.mapAttrs' (
            n: up:
            lib.nameValuePair "${n}.${domain}" {
              extraConfig = "reverse_proxy ${up}";
            }
          ) cfg.proxies)
          // (lib.mapAttrs' (
            from: to:
            lib.nameValuePair from {
              extraConfig = "redir ${to} temporary";
            }
          ) cfg.tempRedirects);

        networking.firewall.allowedTCPPorts = [
          80
          443
        ];
      };
    };
}
