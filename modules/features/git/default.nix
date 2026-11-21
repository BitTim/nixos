{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.git =
    {
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
          };
          credential.helper = "store";
        };
      };
    };
}
