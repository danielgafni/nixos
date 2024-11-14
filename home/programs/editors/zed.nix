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
      "toml"
    ];
    userSettings = {
      auto_update = false;
      magnification = 1.1;
      border_size = 5.0;
      inactive_opacity = 0.9;
      format_on_save = false;
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
      current_line_highlight = "line";
      tabs = {
        file_icons = true;
        git_status = true;
      };
      terminal = {
        env = {
          # use zed as commit editor
          # TODO: enable once remote development supports running the "zed" command properly
          # EDITOR = "zed --wait";
        };
        font_family = "'ZedMono Nerd Font', 'Noto Sans Symbols'";
        copy_on_select = true;
      };
      indent_guides = {
        enabled = true;
        coloring = "indent_aware";
      };
      soft_wrap = "editor_width";
      inlay_hints = {
        enabled = true;
      };
      ssh_connections = [
        {
          host = "devbox";
          projects = [
            {
              paths = ["~/dagster-io/dagster"];
            }
            {
              paths = ["~/dagster-ray"];
            }
            {
              paths = ["~/dagster-io/internal"];
            }
            {
              paths = ["~/dagster-io/dagster-pipes-tests"];
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
