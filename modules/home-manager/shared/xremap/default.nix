_: {
  # https://github.com/xremap/nix-flake/blob/9a2224aa01a3c86e94b398c33329c8ff6496dc5d/docs/HOWTO.md
  services.xremap = {
    enable = false; # not needed for now
    withHypr = true;
    # NuPhy sends PrintScreen via "System Control" device which xremap doesn't auto-detect
    watch = true;
    deviceNames = [
      "NuPhy NuPhy Halo75 V2"
      "NuPhy NuPhy Halo75 V2 Keyboard"
      "NuPhy NuPhy Halo75 V2 System Control"
      "NuPhy NuPhy Halo75 V2 Consumer Control"
    ];
    config = {
      keymap = [
        # {
        #   name = "NuPhy PrintScreen fix";
        #   remap = {
        #     # NuPhy Halo75 V2 sends Super+Shift+S for PrintScreen in Windows mode
        #     # Intercept and convert to actual PrintScreen
        #     "Super-Shift-s" = "Print";
        #   };
        # }
      ];
    };
  };
}
