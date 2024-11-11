{inputs, ...}: {
  programs.zed-editor = {
    enable = true;
    package = inputs.zed.packages.x86_64-linux.zed-editor;
    # read settings.json
    userSettings = builtins.fromJSON (builtins.readFile ./settings.json);
    extensions = [
      "catppuccin-blur"
      "nix"
      "dockerfile"
      "docker-compose"
      "git-firefly"
    ];
    userSettings = {
      auto_update = false;
      buffer_font_family = "FiraCode Nerd Font Mono";
      buffer_font_features = {
        calt = true;
      };
      ui_font_size = 16;
      buffer_font_size = 16;
      theme = {
        mode = "system";
        light = "Catppuccin Espresso (Blur)";
        dark = "Catppuccin Espresso (Blur)";
      };
      terminal = {
        font_family = "ZedMono Nerd Font";
      };
      ssh_connections = [
        {
          host = "devbox";
          projects = [
            {
              paths = ["~/dagster"];
            }
            {
              paths = ["~/dagster-ray"];
            }
            {
              paths = ["~/dagster-io/internal"];
            }
          ];
        }
      ];
      languages = {
        Python = {
          language_servers = ["ruff" "pyright"];
        };
      };
      lsp = {
        pyright = {
          settings = {
            python = {
              pythonPath = ".venv/bin/python";
            };
          };
        };
      };
    };
  };
}
