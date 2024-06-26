{
  pkgs,
  host-settings,
  ...
}: {
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions;
      [
        ms-azuretools.vscode-docker
        catppuccin.catppuccin-vsc
        catppuccin.catppuccin-vsc-icons
        jnoortheen.nix-ide
        github.copilot
        hashicorp.terraform
        ms-kubernetes-tools.vscode-kubernetes-tools
        ms-python.python
        redhat.vscode-yaml
        shd101wyy.markdown-preview-enhanced
        davidanson.vscode-markdownlint
      ]
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "yuck";
          publisher = "eww-yuck";
          version = "0.0.3";
          sha256 = "0c84e02de75a3b421faedb6ef995e489a540ed46b94577388d74073d82eaadc3";
        }
      ];
    userSettings = {
      "workbench.colorTheme" = "Catppuccin Mocha";
      "workbench.iconTheme" = "catppuccin-mocha";
      "window.zoomLevel" = 1;
      "editor.fontFamily" = "FiraCode Nerd Font Mono, Fira Code Symbol, monospace";
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
        "source.fixAll.markdownlint" = true;
      };
      "[markdown]" = {
        "editor.formatOnSave" = false;
        "editor.formatOnPaste" = true;
      };
    };
  };
}
