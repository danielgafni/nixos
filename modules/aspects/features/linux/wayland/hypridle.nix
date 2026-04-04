{den, ...}: {
  den.aspects.hypridle = {
    homeManager = {config, ...}: let
      hd = config.my.hostSettings;
    in {
      services.hypridle = {
        enable = true;
        settings = {
          general = {
            lock_cmd = "pidof hyprlock || hyprlock";
            before_sleep_cmd = "loginctl lock-session";
            after_sleep_cmd = "hyprctl dispatch dpms on";
          };
          listener = hd.wayland.hypridle.listener or [];
        };
      };
    };
  };
}
