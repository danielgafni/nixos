{inputs, ...}: {
  den.aspects = {
    # OS-level mac-app-util (included by MacBook host aspect)
    mac-app-util = {
      darwin = inputs.mac-app-util.darwinModules.default;
    };
    # HM-level mac-app-util (included via shared-hm-darwin)
    mac-app-util-hm = {
      homeManager.imports = [inputs.mac-app-util.homeManagerModules.default];
    };
  };
}
