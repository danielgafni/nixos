_: {
  den.aspects.jankyborders = {
    homeManager = _: {
      services.jankyborders = {
        enable = true;
        settings = {
          # Match Hyprland border colors: Nord-ish active, dark slate inactive.
          active_color = "0xff88c0d0";
          inactive_color = "0xff434c5e";
          width = 3.0;
          hidpi = "on";
        };
      };
    };
  };
}
