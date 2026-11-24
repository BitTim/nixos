{ moduleWithSystem, lib, ... }: {
  flake.nixosModules.forgejo = moduleWithSystem (
    { ... }:
    { config, ... }:
    let
      inherit (lib.lists) head;
      domain = config.my.domain;
      srv = config.services.forgejo.settings.server;
    in
    {
      options.my = {
        forgejo = {
          subdomain = lib.mkOption {
            type = lib.types.str;
            default = "bee";
          };
          adminName = lib.mkOption {
            type = lib.types.str;
            default = "undefbloom";
          };
          adminEmail = lib.mkOption {
            type = lib.types.str;
            default = "lea@anhalt.me";
          };
        };
      };

      config =
        let
          subdomain = config.my.forgejo.subdomain;
          name = config.my.forgejo.adminName;
          email = config.my.forgejo.adminEmail;
        in
        {
          services.forgejo = {
            enable = true;

            database.type = "postgres";
            lfs.enable = true;
            settings = {
              server = {
                DOMAIN = "${subdomain}.${domain}";
                ROOT_URL = "https://${srv.DOMAIN}/";
                HTTP_PORT = 3000;
                SSH_PORT = head config.services.openssh.ports;
              };

              services.DISABLE_REGISTRATION = false; # Temp until user is created
            };
          };

          sops = {
            secrets = {
              forgejo-admin-password = { };
            };
            templates."forgejo.env".content = ''
              FORGEJO_ADMIN_PASSWORD=${config.sops.placeholder.forgejo-admin-password}
            '';
          };

          # Ensure an admin user is present
          systemd.services.forgejo = {
            serviceConfig.EnvironmentFile = config.sops.templates."forgejo.env".path;
            preStart =
              let
                adminCmd = "${lib.getExe config.services.forgejo.package} admin user";
              in
              ''
                ${adminCmd} create --admin --email ${email} --username ${name} --password "$(tr -d '\n' < $FORGEJO_ADMIN_PASSWORD)" || true
              '';
          };

          # SSH config
          services.openssh.settings.AllowUsers = [ "forgejo" ];

          # Reverse Proxy Setup
          services.caddy.virtualHosts = {
            "${subdomain}.internal.${domain}, ${subdomain}.local.${domain}".extraConfig = ''
              tls { dns cloudflare {env.CF_API_TOKEN} }
              reverse_proxy 127.0.0.1:${toString srv.HTTP_PORT}
            '';
            "http://${subdomain}.${domain}".extraConfig = "reverse_proxy 127.0.0.1:${toString srv.HTTP_PORT}";
          };
        };
    }
  );
}
