{den, ...}: {
  den.aspects.services-linux = {
    homeManager = _: {
      services.lorri.enable = true;
    };
  };
}
