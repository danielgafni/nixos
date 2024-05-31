{
  pkgs,
  catppuccin,
  ...
}: {
  programs.k9s = {
    enable = true;
    catppuccin.enable = true;
  };
}
