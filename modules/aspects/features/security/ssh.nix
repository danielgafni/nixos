{den, ...}: {
  den.aspects.ssh = {
    homeManager = _: {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        matchBlocks = {};
      };
    };
  };
}
