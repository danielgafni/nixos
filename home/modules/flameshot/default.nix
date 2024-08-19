{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.module.flameshot;
  screenshotsDir = "Pictures/Screenshots";
  flameshotGrim = pkgs.flameshot.overrideAttrs (oldAttrs: {
    src = pkgs.fetchFromGitHub {
      owner = "flameshot-org";
      repo = "flameshot";
      rev = "3d21e4967b68e9ce80fb2238857aa1bf12c7b905";
      sha256 = "sha256-OLRtF/yjHDN+sIbgilBZ6sBZ3FO6K533kFC1L2peugc=";
    };
    cmakeFlags = [
      "-DUSE_WAYLAND_CLIPBOARD=1"
      "-DUSE_WAYLAND_GRIM=1"
    ];
    buildInputs = oldAttrs.buildInputs ++ [pkgs.libsForQt5.kguiaddons];
  });
in {
  options = {
    module.flameshot.enable = mkEnableOption "Enables Flameshot";
  };

  config = mkIf cfg.enable {
    # create an empty dir for flameshot
    home.file."${screenshotsDir}/.keep" = {
      text = "keep";
    };

    services.flameshot = {
      enable = true;
      package = flameshotGrim;

      settings = {
        General = {
          contrastOpacity = 188;
          disabledTrayIcon = true;
          drawColor = "#89b4fa";
          saveAfterCopy = true;
          saveAsFileExtension = "png";
          savePath = "${config.home.homeDirectory}/${screenshotsDir}";
          savePathFixed = true;
          showDesktopNotification = false;
          showHelp = false;
          showSidePanelButton = false;
          showStartupLaunchMessage = false;
        };

        Shortcuts = {
          TYPE_COPY = "Return";
          TYPE_SAVE = "";
        };
      };
    };
  };
}
