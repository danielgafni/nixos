{
  default,
  config,
  ...
}: let
  textFontSize = 12;
in {
  # Cursor
  home.pointerCursor = {
    size = 16;
  };
  programs.kitty.font.size = textFontSize;
}
