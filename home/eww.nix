{pkgs, ...}: {
  # dependencies for widgets
  home.packages = with pkgs; [
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
    Unit = {Description = "eww";};
    Service = {
      Type = "simple";
      ExecStart = "eww daemon --restart";
      Restart = "on-failure";
    };
    Install = {WantedBy = ["hyprland-session.target"];};
  };
}
