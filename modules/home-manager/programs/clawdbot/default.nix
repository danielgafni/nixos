{
  config,
  pkgs,
  ...
}: let
  homeDir = config.home.homeDirectory;
in {
  programs.clawdbot = {
    enable = true;

    # Disable first-party plugins (they try to download macOS packages)
    firstParty = {
      summarize.enable = false;
      peekaboo.enable = false;
    };

    # Use instances for full config control
    instances.default = {
      enable = true;

      # Workspace and state directories
      workspaceDir = "${homeDir}/clawd";
      stateDir = "${homeDir}/.clawdbot";

      # Anthropic API key
      providers.anthropic.apiKeyFile = config.sops.secrets.CLAUDE_CODE_TOKEN.path;

      # Telegram provider
      providers.telegram = {
        enable = true;
        botTokenFile = config.sops.secrets.CLADW_BOT_TOKEN.path;
        allowFrom = [301446776];
      };

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
  };

  # Additional tools for clawdbot (audio/video processing)
  home.packages = with pkgs; [
    ffmpeg
    openai-whisper
  ];
}
