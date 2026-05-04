{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.programs.commandshift;
in {
  options.programs.commandshift = {
    enable = mkEnableOption "CommandShift — macOS input source switcher (Cmd+Shift)";

    package = mkOption {
      type = types.package;
      description = "The CommandShift package to use.";
    };

    autoStart = mkOption {
      type = types.bool;
      default = true;
      description = "Launch CommandShift automatically at login via launchd.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];

    launchd.agents.commandshift = mkIf cfg.autoStart {
      enable = true;
      config = {
        ProgramArguments = [
          "${cfg.package}/Applications/CommandShift.app/Contents/MacOS/CommandShift"
        ];
        RunAtLoad = true;
        KeepAlive = true;
      };
    };
  };
}
