{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.stax;
in {
  options.programs.stax = {
    enable = mkEnableOption "stax - fast stacked Git branches and PRs";

    package = mkOption {
      type = types.package;
      description = "The stax package to use.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];
  };
}
