{
  default,
  config,
  ...
}: let
  settings = import ./settings.nix;
in {
  programs.kitty.font.size = settings.font.size;

  xdg.configFile.".hostSettings/settings.scss" = {
    text = ''
      @mixing rootContainer {
        font-size = ${toString settings.font.size};
      }
    '';
  };
}
