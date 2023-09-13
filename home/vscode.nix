{ pkgs, ... }: {
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
        ms-azuretools.vscode-docker
        catppuccin.catppuccin-vsc
        catppuccin.catppuccin-vsc-icons
        jnoortheen.nix-ide
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "yuck";
        publisher = "eww-yuck";
        version = "0.0.3";
        sha256 = "0c84e02de75a3b421faedb6ef995e489a540ed46b94577388d74073d82eaadc3";
      }
    ];
  };
}
