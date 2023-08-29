{ pkgs, ... }: {
  # dependencies for widgets
  home.packages = with pkgs; [
    eww-wayland
    socat
    jq # Various scripts and commands
    playerctl # Music info
  ];
  programs.eww = {
    enable = true;
    package = pkgs.eww-wayland;
    configDir = ./.config/eww;
  };
  # Needed for music widget
  services.playerctld.enable = true;

  systemd.user.services.eww = {
    Unit = { Description = "eww"; };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.eww}/bin/eww";
      Restart = "on-failure";
    };
    Install = { WantedBy = [ "hyprland-session.target" ]; };
  };
}

