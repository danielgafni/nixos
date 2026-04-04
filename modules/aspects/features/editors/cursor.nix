{den, ...}: {
  den.aspects.cursor = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [code-cursor];
    };
  };
}
