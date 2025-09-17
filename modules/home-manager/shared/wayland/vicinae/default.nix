_: {
  services.vicinae = {
    enable = true; # default: false
    autoStart = true; # default: true
    # package = # specify package to use here. Can be omitted.
  };

  # create a configfile from ./vicinae.json
  xdg.configFile."vicinae/config.json".source = ./vicinae.json;
}
