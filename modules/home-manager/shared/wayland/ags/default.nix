{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.ags.homeManagerModules.default];

  home.packages = [pkgs.networkmanagerapplet];

  programs.ags = {
    enable = true;

    # additional packages to add to gjs's runtime
    extraPackages = with pkgs; [
      gtksourceview
      webkitgtk
      accountsservice
    ];
  };

  # add ./config directory to ~/.config/ags
  home.file."ags" = {
    source = ./config;
    target = ".config/ags";
    recursive = true;
  };
}
