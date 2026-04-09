{den, ...}: {
  den.aspects = {
    desktop-linux = {
      homeManager = {
        config,
        pkgs,
        lib,
        ...
      }: {
        home = {
          sessionVariables = {
            BROWSER = "google-chrome-stable";
            DEFAULT_BROWSER = "google-chrome-stable";
            NH_FLAKE = "/home/${config.home.username}/nixos";
          };
          file."Media/avatar.jpg".source = ./data/avatar.jpg;
          packages = with pkgs; [qimgv];
        };
        xdg.mimeApps = {
          enable = true;
          defaultApplications = {
            "image/png" = ["qimgv.desktop"];
            "image/jpeg" = ["qimgv.desktop"];
            "inode/directory" = ["yazi.desktop"];
            "application/pdf" = ["org.pwmt.zathura.desktop"];
            "text/plain" = ["dev.zed.Zed.desktop"];
            "text/uri-list" = ["google-chrome.desktop"];
            "x-scheme-handler/http" = ["google-chrome.desktop"];
            "x-scheme-handler/https" = ["google-chrome.desktop"];
            "text/html" = ["google-chrome.desktop"];
            "x-scheme-handler/about" = ["google-chrome.desktop"];
            "x-scheme-handler/unknown" = ["google-chrome.desktop"];
          };
        };
        xdg.portal = {
          config = {
            common.default = ["hyprland" "gtk"];
            hyprland."org.freedesktop.impl.portal.FileChooser" = "gtk";
          };
          extraPortals = [pkgs.xdg-desktop-portal-hyprland pkgs.xdg-desktop-portal-gtk];
        };
        gtk = {
          enable = true;
          font = {
            name = lib.mkForce "Cabin";
            package = lib.mkForce pkgs.cabin;
          };
          gtk3.extraConfig.Settings = ''gtk-application-prefer-dark-theme=1'';
          gtk4.extraConfig.Settings = ''gtk-application-prefer-dark-theme=1'';
        };
        systemd = {
          user.startServices = "sd-switch";
          user.services.mpris-proxy = {
            Unit.Description = "Mpris proxy";
            Unit.After = ["network.target" "sound.target"];
            Service.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
            Install.WantedBy = ["default.target"];
          };
        };
      };
    };

    services-linux = {
      homeManager = _: {
        services.lorri.enable = true;
      };
    };
  };
}
