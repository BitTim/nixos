{
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules.forgejo =
    { config, pkgs, ... }:
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
              DEFAULT.APP_NAME = "Bee";
              server = {
                DOMAIN = "${subdomain}.${domain}";
                ROOT_URL = "https://${srv.DOMAIN}/";
                HTTP_PORT = 3000;
                SSH_PORT = head config.services.openssh.ports;
              };

              ui = {
                DEFAULT_THEME = "forgejo-nixos-pride-auto";
                THEMES = builtins.concatStringsSep "," [
                  # upstream defaults
                  "forgejo-auto"
                  "forgejo-light"
                  "forgejo-dark"
                  # NixOS recolor — this flake's standard variants
                  "forgejo-nixos-auto"
                  "forgejo-nixos-light"
                  "forgejo-nixos-dark"
                  # NixOS recolor + Pride categorical swap
                  "forgejo-nixos-pride-auto"
                  "forgejo-nixos-pride-light"
                  "forgejo-nixos-pride-dark"
                ];
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
          nixpkgs.overlays = [ inputs.forgejo-nixos-themes.overlays.default ];
          systemd.tmpfiles.rules =
            let
              cfg = config.services.forgejo;
            in
            [
              "d '${cfg.customDir}/templates' - ${cfg.user} ${cfg.group} - -"
              "d '${cfg.customDir}/templates/custom' - ${cfg.user} ${cfg.group} - -"
              "L+ '${cfg.customDir}/templates/home.tmpl' - - - - ${./home.tmpl}"
              "L+ '${cfg.customDir}/templates/custom/extra_links.tmpl' - - - - ${./extra_links.tmpl}"

              "d ${cfg.customDir}/public 0755 ${cfg.user} ${cfg.group} - -"
              "L+ '${cfg.customDir}/public/assets' - - - - ${pkgs.forgejo-nixos-themes}/assets"
            ];
        };
    };
}
