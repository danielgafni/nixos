{
  inputs,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # Nix language servers
    nixd
    nil
    # zig language server
    zls

    # rust dev
    cargo
    rustc
    rust-analyzer
    clippy

    # misc
    typos
    typos-lsp # language server for typos
  ];
  programs.zed-editor = {
    enable = true;
    package = inputs.zed.packages.x86_64-linux.default;
    extensions = [
      "catppuccin"
      "catppuccin-blur"
      "nix"
      "dockerfile"
      "docker-compose"
      "git-firefly"
      "helm"
      "markdown-oxide"
      "toml"
      "zig"
      "typos"
    ];
    userSettings = {
      auto_update = false;
      magnification = 1.1;
      border_size = 5.0;
      inactive_opacity = 0.9;
      format_on_save = "off";
      buffer_font_family = "'Fira Code Nerd Fonts Mono', 'Fira Code', 'ZedMono Nerd Font', 'Noto Sans Symbols', 'Symbols Nerd Font Mono'";
      buffer_font_features = {
        calt = true;
      };
      ui_font_size = 16;
      buffer_font_size = 15;
      buffer_font_fallbacks = ["'Symbols Nerd Font Mono'"];
      theme = {
        mode = "system";
        # light = lib.mkForce "Catppuccin Latte";
        # dark = lib.mkForce "Catppuccin Mocha";
      };
      current_line_highlight = "line";
      tabs = {
        file_icons = true;
        git_status = true;
      };
      terminal = {
        line_height = "standard";
        env = {
          # use zed as commit editor
          # TODO: enable once remote development supports running the "zed" command properly
          # EDITOR = "zed --wait";
        };
        font_family = "'Fira Code Nerd Fonts Mono', 'Fira Code', 'ZedMono Nerd Font', 'Noto Sans Symbols', 'Symbols Nerd Font Mono'";
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
          # the here order matters!
          # for example, "jump to definition" doesn't work with ruff, pyright order
          language_servers = ["pyright" "ruff"];
        };
        Zig = {
          language_servers = ["zls"];
        };
      };
      lsp = {
        nil = {
          settings = {
            autoArchive = true;
          };
        };
        pyright = {
          settings = {
            python = {
              pythonPath = ".venv/bin/python";
            };
          };
        };
        yaml-language-server = {
          settings = {
            editor = {
              tabSize = 2;
            };
          };
        };
        rust-analyzer = {
          initialization_options = {
            cargo = {
              allFeatures = true;
              buildScripts = {
                rebuildOnSave = true;
              };
            };
            procMacro = {
              enable = true;
            };
            checkOnSave = {
              command = "clippy";
            };
            hover = {
              references = {
                enabled = true;
              };
            };
          };
        };
        typos = {
          initialization_options = {
            # Path to your typos config file, .typos.toml by default.
            config = ".typos.toml";
            # Diagnostic severity within Zed. "Error" by default, can be:
            # "Error", "Hint", "Information", "Warning"
            diagnosticSeverity = "Error";
            # Minimum logging level for the LSP, displayed in Zed's logs. "info" by default, can be:
            # "debug", "error", "info", "off", "trace", "warn"
            logLevel = "info";
            # Traces the communication between ZED and the language server. Recommended for debugging only. "off" by default, can be:
            # "messages", "off", "verbose"
            trace.server = "off";
          };
        };
      };
    };
  };
}
