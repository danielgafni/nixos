{den, ...}: {
  den.aspects.underdel-linux = {
    includes = [
      den.aspects.underdel
      # Linux shared HM features
      den.aspects.shared-hm-linux
    ];
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        # wayland/DE
        libnotify
        hyprpicker
        grim
        slurp
        wl-clipboard
        font-manager
        dconf

        # audio
        pipewire
        wireplumber

        # extra
        xarchiver
        mpv
        vlc
      ];
    };
  };
}
