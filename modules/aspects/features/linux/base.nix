_: {
  den.aspects.base-linux = {
    homeManager = {
      config,
      lib,
      ...
    }: {
      home.pointerCursor = {size = config.my.hostSettings.cursor.size or 24;};
      catppuccin.cursors = {
        enable = true;
        accent = "teal";
      };
    };
  };
}
