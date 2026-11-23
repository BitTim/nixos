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

      options.my.caddy.trustedProxies = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };

      config = {
        services.caddy = {
          package = pkgs.caddy.withPlugins {
            plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
          };
          environmentFile = config.sops.secrets."caddy-env".path;
          globalConfig = lib.mkIf (config.my.caddy.trustedProxies != [ ]) ''
            servers { trusted_proxies static ${lib.concatStringsSep " " config.my.caddy.trustedProxies} }
            	'';
        };

        sops.secrets."caddy-env" = { };
        networking.firewall.allowedTCPPorts = [ 443 ];
      };
    }
  );
}
