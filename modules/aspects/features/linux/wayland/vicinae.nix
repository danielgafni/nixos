{
  den,
  inputs,
  ...
}: {
  den.aspects.vicinae = {
    homeManager = {pkgs, ...}: let
      inherit (inputs.vicinae.packages.${pkgs.stdenv.hostPlatform.system}) mkRayCastExtension;
      extensionRev = "e7bfcf07b410e7dde824b6b80c673f336c882567";
      rayCastExtensions = [
        {
          name = "1password";
          hash = "sha256-I1STC8w316kV8It3Be35mwLvNSYPJqy1bG+XaIRMRpg=";
          rev = extensionRev;
        }
        {
          name = "linear";
          hash = "sha256-Zgzx6ZE31vugqa8M755kXp0s/xA3ArLjZZe2XVaTjLE=";
          rev = extensionRev;
        }
      ];
    in {
      # Theme handled by catppuccin.vicinae.enable (globally enabled)
      services.vicinae = {
        enable = true;
        systemd.enable = true;
        extensions = builtins.map mkRayCastExtension rayCastExtensions;
        settings = {
          favicon_service = "twenty";
          pop_to_root_on_close = true;
          search_files_in_root = false;
          font.normal = {
            family = "Cabin";
            size = 10;
          };
          launcher_window = {
            csd = true;
            opacity = 0.7;
            rounding = 10;
          };
        };
      };
    };
  };
}
