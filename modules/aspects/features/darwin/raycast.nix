_: {
  den.aspects.raycast = {
    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.raycast];
    };
  };
}
