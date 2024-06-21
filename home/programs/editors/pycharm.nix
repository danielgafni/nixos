{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    jetbrains.pycharm-professional
  ];

  # pycharm custom vmoptions
  # point PYCHARM_VM_OPTIONS to this file

  home.sessionVariables.PYCHARM_VM_OPTIONS = "${config.home.homeDirectory}/${config.xdg.configFile."pycharm/pycharm64.vmoptions".target}";

  # memory settings and wayland compatibility
  xdg.configFile."pycharm/pycharm64.vmoptions" = {
    recursive = true;
    text = ''
      -Xmx8G
      -Xms4G
      -XX:NewRatio=1
      -Dawt.toolkit.name=WLToolkit
    '';
  };
}
