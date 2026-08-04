{den, ...}: {
  den.aspects.ssh = {
    homeManager = _: {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        # SkyPilot writes per-cluster stanzas to ~/.sky/generated/ssh/ and expects
        # this exact Include line at the top of ~/.ssh/config; if it finds it, it
        # never tries to write the (read-only, nix-store) config itself. It matches
        # the line by EXACT string, so the include must stand alone — home-manager's
        # `includes` option space-joins all entries onto one `Include a b c` line
        # (which wouldn't match), so we emit it via extraOptionOverrides, which
        # renders one directive per line at the very top (before any Host block).
        extraOptionOverrides.Include = "~/.sky/generated/ssh/*";
        matchBlocks = {};
      };
    };
  };
}
