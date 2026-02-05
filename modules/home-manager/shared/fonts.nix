{pkgs, ...}: {
  fonts.fontconfig.enable = true;

  # Workaround for Zed not reading conf.d directory
  # See: https://github.com/zed-industries/zed/issues/18982
  xdg.configFile."fontconfig/fonts.conf".text = ''
    <?xml version='1.0'?>
    <!DOCTYPE fontconfig SYSTEM 'urn:fontconfig:fonts.dtd'>
    <fontconfig>
      <include ignore_missing="yes">conf.d</include>
    </fontconfig>
  '';

  home.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.zed-mono
    nerd-fonts.symbols-only

    recursive # for eww
    #fira-code
    #fira-code-symbols
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    liberation_ttf
    cabin
    maple-mono.NF
    maple-mono.truetype
    orbitron
  ];
}
