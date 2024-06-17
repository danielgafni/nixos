{
  default,
  config,
  ...
}: let
  textFontSize = 18;
in {
  # Cursor
  home.pointerCursor = {
    size = 20;
  };
  gtk.cursorTheme.size = 20;
  programs.kitty.font.size = textFontSize;

  xdg.configFile.".hostSettings/settings.scss" = {
    text = ''
      @mixing rootContainer {
        font-size = ${toString textFontSize};
      }
    '';
  };
}
