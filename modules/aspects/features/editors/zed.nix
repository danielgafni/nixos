{
  den,
  inputs,
  ...
}: {
  den.aspects = {
    zed = {
      homeManager = {pkgs, ...}: {
        home.packages = with pkgs; [nixd nil zls cargo rustc rust-analyzer clippy typos typos-lsp];
        programs.zed-editor = {
          enable = true;
          package = pkgs.zed-editor;
          extensions = ["catppuccin" "catppuccin-icons" "catppuccin-blur" "nix" "dockerfile" "docker-compose" "git-firefly" "helm" "markdown-oxide" "toml" "zig" "typos" "justfile" "sql" "sqlruff" "csv" "basedpyright" "ty"];
          userKeymaps = [
            {
              context = "Editor && edit_prediction";
              bindings = {
                "tab" = "editor::AcceptEditPrediction";
                "alt-l" = null;
              };
            }
            {
              context = "Editor && edit_prediction_conflict";
              bindings = {
                "alt-tab" = "editor::AcceptEditPrediction";
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
            buffer_font_family = "Maple Mono NF";
            buffer_font_features = {calt = true;};
            ui_font_family = "Cabin";
            ui_font_size = 18;
            buffer_font_size = 17;
            buffer_font_fallbacks = ["Symbols Nerd Font Mono"];
            double_click_in_multibuffer = "open";
            theme = {mode = "system";};
            current_line_highlight = "line";
            tabs = {
              file_icons = true;
              git_status = true;
            };
            terminal = {
              line_height = "standard";
              env = {};
              font_family = "Maple Mono NF";
              copy_on_select = true;
            };
            indent_guides = {
              enabled = true;
              coloring = "indent_aware";
            };
            soft_wrap = "editor_width";
            inlay_hints = {enabled = true;};
            ssh_connections = [
              {
                host = "devbox";
                projects = [
                  {paths = ["~/dagster-io/dagster"];}
                  {paths = ["~/dagster-ray"];}
                  {paths = ["~/dagster-io/internal"];}
                  {paths = ["~/dagster-io/dagster-pipes-tests"];}
                ];
              }
            ];
            languages = {
              Python = {language_servers = ["ty" "ruff" "!basedpyright"];};
              Zig = {language_servers = ["zls"];};
              Nix = {language_servers = ["nil"];};
            };
            lsp = import ./_lsp.nix;
            show_edit_predictions = true;
            features = {edit_prediction_provider = "zed";};
            agent = {
              enabled = true;
              always_allow_tool_actions = true;
              default_model = {
                provider = "anthropic";
                model = "claude-opus-4.5";
              };
              inline_assistant_model = {
                provider = "anthropic";
                model = "claude-opus-4.5";
              };
              inline_alternatives = [
                {
                  provider = "zed.dev";
                  model = "gpt-5";
                }
              ];
            };
            language_models = {
              anthropic = {
                available_models = [
                  {
                    name = "claude-opus-4.5";
                    display_name = "Claude Opus 4.5";
                    max_tokens = 128000;
                    max_output_tokens = 2560;
                  }
                ];
              };
            };
            context_servers = {
              nixos = {
                command = "uvx";
                args = ["mcp-nixos"];
              };
              kubernetes = {
                command = "npx";
                args = ["mcp-server-kubernetes"];
              };
            };
          };
        };
      };
    };

    zed-linux = {
      homeManager = {
        pkgs,
        lib,
        ...
      }: {
        programs.zed-editor.package = lib.mkForce inputs.chaotic.packages.${pkgs.stdenv.hostPlatform.system}.zed-editor_git;
      };
    };
  };
}
