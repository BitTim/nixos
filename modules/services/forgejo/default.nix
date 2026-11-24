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

              services.DISABLE_REGISTRATION = true;
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
                ${adminCmd} create --admin --email ${email} --username ${name} --password "$FORGEJO_ADMIN_PASSWORD" || true
              '';
          };

          # SSH config
          services.openssh.settings.AllowUsers = [ "forgejo" ];

          # Reverse Proxy Setup
          my.proxy.${subdomain}.port = config.services.forgejo.settings.server.HTTP_PORT;
        };
    }
  );
}
