{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.stax;
  # Shell wrapper that `cd`s into worktrees (e.g. `st co` routing to a branch's worktree).
  shellIntegration = pkgs.runCommand "stax-shell-setup.sh" {} ''
    HOME=$TMPDIR SHELL=zsh STAX_DISABLE_UPDATE_CHECK=1 ${getExe' cfg.package "stax"} setup --print > $out
  '';
in {
  options.programs.stax = {
    enable = mkEnableOption "stax - fast stacked Git branches and PRs";

    package = mkOption {
      type = types.package;
      description = "The stax package to use.";
    };

    enableZshIntegration = mkOption {
      type = types.bool;
      default = true;
      description = "Source the stax shell integration (worktree auto-cd) in zsh.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];
    programs.zsh.initContent = mkIf cfg.enableZshIntegration ''
      source ${shellIntegration}
    '';
  };
}
