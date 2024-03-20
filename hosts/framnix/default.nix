{
  default,
  config,
  ...
}: let
  settings = import ./settings.nix;
in {
  programs.kitty.font.size = settings.font.size;
}
