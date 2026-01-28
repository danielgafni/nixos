# Shared clawdbot configuration base
# This module provides common settings; host-specific modules set the instance config
{
  config,
  pkgs,
  lib,
  ...
}: {
  options.programs.clawdbot.baseConfig = lib.mkOption {
    type = lib.types.attrs;
    default = {};
    description = "Base configuration to be merged with host-specific settings";
  };

  config = {
    programs.clawdbot = {
      enable = true;

      # Disable first-party plugins (they try to download macOS packages)
      firstParty = {
        summarize.enable = false;
        peekaboo.enable = false;
      };
    };

    # Shared base config that host modules can reference
    programs.clawdbot.baseConfig = let
      homeDir = config.home.homeDirectory;
    in {
      enable = true;

      # Workspace and state - uses shared git repo
      workspaceDir = "${homeDir}/clawd";
      stateDir = "${homeDir}/.clawdbot";

      # Anthropic API key (shared across hosts)
      providers.anthropic.apiKeyFile = config.sops.secrets.CLAUDE_CODE_TOKEN.path;

      # Agent settings
      agent = {
        model = "anthropic/claude-opus-4-5";
        thinkingDefault = "high";
      };

      # Message routing
      routing.queue = {
        mode = "interrupt";
        byProvider = {
          discord = "queue";
          telegram = "interrupt";
          webchat = "queue";
        };
      };

      # Systemd service (Linux)
      systemd.enable = true;
    };

    # Additional tools for clawdbot (audio/video processing)
    home.packages = with pkgs; [
      ffmpeg
      openai-whisper
    ];
  };
}
