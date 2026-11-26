{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.git =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      programs.git = {
        enable = true;
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.git;
      };
      programs.gnupg.agent = {
        enable = true;
        pinentryPackage = pkgs.pinentry-all;
      };

      sops.secrets.gpg-signing-key = {
        sopsFile = "../../../secrets/git.yaml";
        owner = config.my.user.name;
      };

      systemd.user.services.gpg-import-signing-key = {
        description = "Import git signing key";
        wantedBy = [ "default.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          ${pkgs.gnupg}/bin/gpg --batch --quiet --import ${config.sops.secrets.gpg-signing-key.path}
        '';
      };
    };
  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    {
      packages.git = inputs.wrappers.wrappers.git.wrap {
        inherit pkgs;
        settings = {
          user = {
            email = "lea@anhalt.me";
            name = "Lea Anhalt";
            signingkey = "2D096CBBD80E9D00";
          };
          commit.gpgsign = true;
          tag.gpgsign = true;
          gpg.program = "${pkgs.gnupg}/bin/gpg";
          credential.helper = "store";
        };
      };
    };
}
