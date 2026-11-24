{
  self,
  moduleWithSystem,
  lib,
  ...
}:
{
  flake.nixosModules.caddy-internal = moduleWithSystem (
    { pkgs, ... }: { config, ... }: {
      imports = [ self.nixosModules.caddy ];

      options.my = {
        caddy.trustedProxies = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };

        proxy = lib.mkOption {
          default = { };
          type = lib.types.attrsOf (
            lib.types.submodule (
              { name, ... }: {
                options = {
                  subdomain = lib.mkOption {
                    type = lib.types.str;
                    default = name;
                  };
                  port = lib.mkOption { type = lib.types.port; };
                  public = lib.mkOption {
                    type = lib.types.bool;
                    default = true;
                  };
                };
              }
            )
          );
        };
      };

      config = {
        services.caddy = {
          package = pkgs.caddy.withPlugins {
            plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
            hash = "sha256-QSiwKqKvSxhksWBF4/MlBOpyXba5xOQ2sRwA0R7399E=";
          };
          environmentFile = config.sops.secrets."caddy-env".path;
          globalConfig = lib.mkIf (config.my.caddy.trustedProxies != [ ]) ''
            servers { trusted_proxies static ${lib.concatStringsSep " " config.my.caddy.trustedProxies} }
            	'';

          virtualHosts = lib.mkMerge (
            lib.mapAttrsToList (
              _: svc:
              let
                subdomain = svc.subdomain;
                domain = config.my.domain;
                upstream = "reverse_proxy 127.0.0.1:${toString svc.port}";
              in
              {
                "${subdomain}.internal.${domain}, ${subdomain}.local.${domain}".extraConfig = ''
                  tls { dns cloudflare {env.CF_API_TOKEN} }
                  ${upstream}
                '';
              }
              // lib.optionalAttrs svc.public {
                "http://${subdomain}.${domain}".extraConfig = upstream;
              }
            ) config.my.proxy
          );
        };

        sops.secrets."caddy-env" = { };
        networking.firewall.allowedTCPPorts = [ 443 ];
      };
    }
  );
}
