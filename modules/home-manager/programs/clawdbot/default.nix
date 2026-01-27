{
  config,
  pkgs,
  ...
}: let
  homeDir = config.home.homeDirectory;
  apiKeyFile = config.sops.secrets.CLAUDE_CODE_TOKEN.path;

  # Fetch clawdbot source for bundled plugins (memory-core, etc.)
  clawdbotSource = pkgs.fetchFromGitHub {
    owner = "clawdbot";
    repo = "clawdbot";
    rev = "6859e1e6a66691282f2394cd8f8ab2eef3e8c45d";
    hash = "sha256-8TPwkKzctOgtXLK5cDYMW+i7gVmcjfo48xVaeuWoCLQ=";
  };

  clawdbotConfig = {
    gateway.mode = "local";
    plugins.slots.memory = "memory-core";
    agents = {
      defaults = {
        workspace = "${homeDir}/clawd";
        model.primary = "anthropic/claude-opus-4-5";
        thinkingDefault = "high";
        skipBootstrap = true;
      };
      list = [
        {
          id = "main";
          default = true;
        }
      ];
    };
    channels.telegram = {
      enabled = true;
      tokenFile = config.sops.secrets.CLADW_BOT_TOKEN.path;
      allowFrom = [301446776];
    };
    messages.queue = {
      mode = "interrupt";
      byChannel = {
        discord = "queue";
        telegram = "interrupt";
        webchat = "queue";
      };
    };
  };

  gatewayWrapper = pkgs.writeShellScript "clawdbot-gateway-wrapper" ''
    set -euo pipefail
    if [ ! -f "${apiKeyFile}" ]; then
      echo "Error: API key file not found: ${apiKeyFile}" >&2
      exit 1
    fi
    ANTHROPIC_API_KEY=$(cat "${apiKeyFile}")
    if [ -z "$ANTHROPIC_API_KEY" ]; then
      echo "Error: API key file is empty: ${apiKeyFile}" >&2
      exit 1
    fi
    export ANTHROPIC_API_KEY
    exec ${pkgs.clawdbot-gateway}/bin/clawdbot gateway --port 18789
  '';
in {
  home = {
    packages = [
      pkgs.clawdbot-gateway
      # Audio/video processing for clawdbot
      pkgs.ffmpeg
      pkgs.openai-whisper
    ];

    activation.clawdbotSetup = config.lib.dag.entryAfter ["writeBoundary"] ''
      run mkdir -p "$HOME/.clawdbot" "$HOME/clawd"

      echo '${builtins.toJSON clawdbotConfig}' > "$HOME/.clawdbot/clawdbot.json"
      run chmod 600 "$HOME/.clawdbot/clawdbot.json"
    '';
  };

  systemd.user.services.clawdbot-gateway = {
    Unit.Description = "Clawdbot gateway";
    Service = {
      ExecStart = "${gatewayWrapper}";
      WorkingDirectory = "${homeDir}/.clawdbot";
      Restart = "always";
      RestartSec = "1s";
      Environment = [
        "HOME=${homeDir}"
        "CLAWDBOT_CONFIG_PATH=${homeDir}/.clawdbot/clawdbot.json"
        "CLAWDBOT_STATE_DIR=${homeDir}/.clawdbot"
        "CLAWDBOT_BUNDLED_PLUGINS_DIR=${clawdbotSource}/extensions"
      ];
    };
    Install.WantedBy = ["default.target"];
  };
}
