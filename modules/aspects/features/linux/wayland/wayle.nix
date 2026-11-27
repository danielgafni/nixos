# Wayle replaces HyprPanel, which upstream archived; nixpkgs now throws on
# `hyprpanel` and points at `wayle`. Wayle ships no home-manager module, so the
# TOML config and the user service are declared here directly.
{den, ...}: {
  den.aspects.wayle = {
    homeManager = {
      config,
      lib,
      pkgs,
      ...
    }: let
      hd = config.my.hostSettings;
      wayleData = hd.wayle or {};
      tomlFormat = pkgs.formats.toml {};

      # Catppuccin Mocha, to match the rest of the desktop theming.
      palette = {
        bg = "#1e1e2e";
        surface = "#313244";
        elevated = "#45475a";
        fg = "#cdd6f4";
        fg-muted = "#a6adc8";
        primary = "#cba6f7";
        red = "#f38ba8";
        yellow = "#f9e2af";
        green = "#a6e3a1";
        blue = "#89b4fa";
      };

      settings = {
        general = {
          font-sans = "Recursive Sans Casual Static Italic";
          font-mono = "JetBrains Mono";
        };

        bar = {
          location = "top";
          # HyprPanel's theme.bar.transparent = true.
          background-opacity = 0;
          border-location = "none";
          layout = [
            {
              monitor = "*";
              show = true;
              left = ["dashboard" "hyprland-workspaces" "window-title"];
              center = ["media"];
              right = wayleData.modules.right or [];
            }
          ];
        };

        styling.palette = palette;

        modules = {
          # HyprPanel had separate `cpu` and `cputemp` modules; wayle's cpu
          # module carries both through its format placeholders.
          cpu = {
            temp-sensor = wayleData.modules.cpu.tempSensor or "auto";
            format = "{{ percent }}% {{ temp_c }}C";
          };

          hyprland-workspaces = {
            min-workspace-count = 5;
            app-icons-show = true;
          };

          weather.location = wayleData.weather.location or "Bucharest";
        };
      };
    in {
      xdg.configFile."wayle/config.toml".source =
        tomlFormat.generate "wayle-config.toml" settings;

      systemd.user.services.wayle = {
        Unit = {
          Description = "Wayle desktop shell";
          PartOf = ["graphical-session.target"];
          After = ["graphical-session.target"];
        };
        Service = {
          ExecStart = "${lib.getExe' pkgs.wayle "wayle"} shell";
          Restart = "on-failure";
          RestartSec = 3;
        };
        Install.WantedBy = ["graphical-session.target"];
      };

      home.packages = with pkgs; [
        wayle
        # Optional helpers the panel shells out to.
        gpustat
        gpu-screen-recorder
        hyprpicker
        hyprsunset
        btop
        matugen
        awww
        grimblast
      ];
    };
  };
}
