{den, ...}: {
  den.aspects.base = {
    homeManager = {
      pkgs,
      lib,
      ...
    }: let
      catppuccinFlavor = "mocha";
    in {
      home = {
        stateVersion = "22.11";
      };
      catppuccin = {
        enable = true;
        flavor = catppuccinFlavor;
      };
      xdg.enable = true;
      programs = {
        home-manager.enable = true;
        dircolors.enable = true;
        btop.enable = true;
        zathura.enable = true;
      };
      news = {
        display = "silent";
        json = lib.mkForce {};
        entries = lib.mkForce [];
      };
      home.packages = with pkgs; [unzip jq];
    };
  };
}
