{
  pkgs,
  host-settings,
  vsCodeExtensionsPythonPinnedPkgs,
  ...
}: let
  lsp = import ./lsp.nix;
in {
  home.packages = with pkgs; [
    nil # Nix language server
    fira-code
  ];
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;
    profiles.default = {
      enableUpdateCheck = false;
      extensions = with pkgs.vscode-extensions;
        [
          ms-azuretools.vscode-docker
          catppuccin.catppuccin-vsc
          catppuccin.catppuccin-vsc-icons
          jnoortheen.nix-ide
          github.copilot
          hashicorp.terraform
          ms-kubernetes-tools.vscode-kubernetes-tools
          # ms-python.python
          redhat.vscode-yaml
          shd101wyy.markdown-preview-enhanced
          davidanson.vscode-markdownlint
          dbaeumer.vscode-eslint
          hashicorp.hcl
          rust-lang.rust-analyzer
        ]
        ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "grafana-alloy";
            publisher = "Grafana";
            version = "0.2.0";
            sha256 = "5dca2210308fa7a1b36100e1240ad90445b14a766b4931e87c8c8b15e82c6e1d";
          }
        ]
        ++ [
          vsCodeExtensionsPythonPinnedPkgs.vscode-extensions.ms-python.python
        ];
      userSettings = {
        "workbench.colorTheme" = "Catppuccin Mocha";
        "workbench.iconTheme" = "catppuccin-mocha";
        "window.zoomLevel" = 1;
        "editor.fontFamily" = "'Fira Code Nerd Fonts Mono', 'Fira Code', 'Fira Code Symbol', 'Symbols Nerd Font Mono', monospace";
        "terminal.integrated.fontFamily" = "'Fira Code Nerd Fonts Mono', 'Fira Code', 'Fira Code Symbol', 'Symbols Nerd Font Mono', monospace";
        "editor.fontSize" = host-settings.font.text.size;
        "terminal.integrated.fontSize" = host-settings.font.text.size;
        "github.copilot.enable" = {
          "*" = true;
          "plaintext" = false;
          "markdown" = false;
          "scminput" = false;
        };
        "editor.fontLigatures" = "'ss09', 'zero', 'cv27', 'ss10'"; # https://github.com/tonsky/FiraCode/wiki/How-to-enable-stylistic-sets

        "editor.codeActionsOnSave" = {
          # "source.fixAll.markdownlint" = true;
        };
        "[markdown]" = {
          "editor.formatOnSave" = false;
          "editor.formatOnPaste" = true;
        };
        "nix.enableLanguageServer" = true; # Enable LSP.
        "nix.serverPath" = "nil"; # The path to the LSP server executable.
        "nix.serverSettings" = {inherit (lsp) nil;}; # The settings to pass to the LSP server.
      };
    };
  };
}
