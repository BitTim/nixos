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

              service.DISABLE_REGISTRATION = true;
            };
          };

          sops.secrets.forgejo-admin-password = { };
          sops.secrets.forgejo-admin-password.owner = "forgejo";

          # Ensure an admin user is present
          systemd.services.forgejo.preStart =
            let
              adminCmd = "${lib.getExe config.services.forgejo.package} admin user";
              pwd = config.sops.secrets.forgejo-admin-password;
            in
            ''
              ${adminCmd} create --admin --email "${email}" --username "${name}" --password "$(tr -d '\n' < ${pwd.path})" || true
            '';

          # SSH config
          services.openssh.settings.AllowUsers = [ "forgejo" ];

          # Reverse Proxy Setup
          my.proxy.${subdomain}.port = config.services.forgejo.settings.server.HTTP_PORT;

          # Theming
          systemd.tmpfiles.rules =
            let
              customDir = config.services.forgejo.customDir;
            in
            [
              "d '${customDir}/templates' - forgejo forgejo - -"
              "d '${customDir}/templates/custom' - forgejo forgejo - -"
              "d '${customDir}/public' - forgejo forgejo - -"
              "d '${customDir}/public/assets' - forgejo forgejo - -"
              "d '${customDir}/public/assets/css' - forgejo forgejo - -"
              "L+ '${customDir}/templates/home.tmpl' - - - - ${./home.tmpl}"
              "L+ '${customDir}/templates/custom/extra_links.tmpl' - - - - ${./extra_links.tmpl}"
            ];
        };
    }
  );
}
