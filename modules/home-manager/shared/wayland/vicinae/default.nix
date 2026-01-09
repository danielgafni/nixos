{
  config,
  lib,
  ...
}: let
  extensionRev = "e7bfcf07b410e7dde824b6b80c673f336c882567";
  rayCastExtensions = [
    {
      name = "1password";
      # sha256 = lib.fakeSha256;
      sha256 = "I1STC8w316kV8It3Be35mwLvNSYPJqy1bG+XaIRMRpg=";
      rev = extensionRev;
    }
    #    {
    #      name = "zed";
    #      sha256 = lib.fakeSha256;
    #      rev = extensionRev;
    #    }
    {
      name = "linear";
      sha256 = "Zgzx6ZE31vugqa8M755kXp0s/xA3ArLjZZe2XVaTjLE=";
      rev = extensionRev;
    }
  ];
in {
  programs.vicinae = {
    enable = true;
    systemd.enable = true;
    extensions = builtins.map config.lib.vicinae.mkRayCastExtension rayCastExtensions;
  };

  # create a configfile from ./vicinae.json
  xdg.configFile."vicinae/config.json".source = ./vicinae.json;
}
