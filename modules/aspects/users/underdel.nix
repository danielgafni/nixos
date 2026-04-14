{den, ...}: {
  den.aspects.underdel = {
    includes = [
      den.provides.define-user
      # Shared HM features (cross-platform)
      den.aspects.shared-hm
    ];
    nixos.users.users.underdel = {
      initialPassword = "pw123";
      extraGroups = [
        "video"
        "networkmanager"
      ];
    };
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        # CLI
        comma
        curl
        wget
        zsh
        eza
        just

        # messengers
        telegram-desktop

        # browsers
        google-chrome
        firefox
      ];
    };
  };
}
