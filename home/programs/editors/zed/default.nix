{
  inputs,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # Nix language servers
    nixd
    nil
  ];
  programs.zed-editor = {
    enable = true;
    package = inputs.zed.packages.x86_64-linux.zed-editor;
    extensions = [
      "catppuccin-blur"
      "nix"
      "dockerfile"
      "docker-compose"
      "git-firefly"
      "helm"
      "markdown-oxide"
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
        env = {
          # use zed as commit editor
          # TODO: enable once remote development supports running the "zed" command properly
          # EDITOR = "zed --wait";
        };
        font_family = "'ZedMono Nerd Font', 'Noto Sans Symbols'";
      };
      indent_guides = {
        enabled = true;
        coloring = "indent_aware";
      };
      inlay_hints = {
        enabled = true;
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
