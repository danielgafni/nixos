{
  inputs,
  pkgs,
  zedNixPkgs,
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

    # python dev
    # basedpyright
  ];
  programs.zed-editor = {
    enable = true;
    package = inputs.chaotic.packages.x86_64-linux.zed-editor_git;
    extensions = [
      "catppuccin"
      "catppuccin-icons"
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
      "justfile"
      "sql"
      "sqlruff"
      "csv"
      "basedpyright"
    ];
    userKeymaps = [
      {
        context = "Editor && edit_prediction";
        bindings = {
          "tab" = "editor::AcceptEditPrediction";
          # Optional: This makes the default `alt-l` binding do nothing.
          "alt-l" = null;
        };
      }
      {
        context = "Editor && edit_prediction_conflict";
        bindings = {
          "alt-tab" = "editor::AcceptEditPrediction";
          # Optional: This makes the default `alt-l` binding do nothing.
          "alt-l" = null;
        };
      }
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
      ui_font_size = 18;
      buffer_font_size = 17;
      buffer_font_fallbacks = ["'Symbols Nerd Font Mono'"];
      theme = {
        mode = "system";
        # light = lib.mkForce "Catppuccin Latte";
        # dark = lib.mkForce "Catppuccin Mocha";
      };
      # icon_theme = {
      #   mode = "system";
      # TODO: infer from catppuccin-nix instead once https://github.com/catppuccin/nix/pull/467 is merged
      # light = "Catppuccin Mocha";
      # dark = "Catppuccin Mocha";
      # };
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
          # for example, "go to definition" doesn't work with [ruff, pyright] order
          language_servers = ["basedpyright" "ruff"];
        };
        Zig = {
          language_servers = ["zls"];
        };
        Nix = {
          language_servers = ["nil"];
        };
      };
      lsp = import ./lsp.nix;
      show_edit_predictions = true;
      features = {
        edit_prediction_provider = "zed"; # alternative: "copilot"
      };
      assistant = {
        enabled = true;
        version = "2";
        default_model = {
          provider = "copilot_chat";
          model = "gpt-4o";
        };
        always_allow_tool_actions = true;
        inline_alternatives = [
          {
            provider = "zed.dev";
            model = "claude-3-5-sonnet-latest";
          }
          {
            provider = "zed.dev";
            model = "gpt-4o";
          }
          {
            provider = "copilot_chat";
            model = "o1-preview";
          }
        ];
      };
      context_servers = {
        nixos = {
          command = {
            path = "uvx";
            args = ["mcp-nixos"];
          };
        };
      };
    };
  };
}
