{
  default,
  config,
  ...
}: let
  settings = import ./settings.nix;
in {
  xdg.configFile.".hostSettings/settings.scss" = {
    text = ''
      @mixing rootContainer {
        font-size = ${toString settings.font.size};
      }
    '';
  };
}
