{
  config,
  pkgs,
  ...
}: let
  # Fetch clawdbot source to get the bundled extensions and templates
  # The nix-clawdbot package doesn't include the extensions or docs/templates directories
  clawdbotSource = pkgs.fetchFromGitHub {
    owner = "clawdbot";
    repo = "clawdbot";
    rev = "6859e1e6a66691282f2394cd8f8ab2eef3e8c45d";
    hash = "sha256-8TPwkKzctOgtXLK5cDYMW+i7gVmcjfo48xVaeuWoCLQ=";
  };

  # Base config that we manage via Nix
  # Use ~/clawd workspace which is the default and matches the templates we provide
  clawdbotConfig = {
    gateway.mode = "local";
    plugins.slots.memory = "memory-core";
    agents = {
      defaults = {
        workspace = "${config.home.homeDirectory}/clawd";
        model.primary = "anthropic/claude-opus-4-5";
        thinkingDefault = "high";
        skipBootstrap = true; # Skip loading templates from nix store (they don't exist there)
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
      groups = {};
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

  configJson = builtins.toJSON clawdbotConfig;

  # API key file path
  anthropicApiKeyFile = config.sops.secrets.CLAUDE_CODE_TOKEN.path;

  # Wrapper script that reads API key from file and starts the gateway
  gatewayWrapper = pkgs.writeShellScript "clawdbot-gateway-wrapper" ''
    set -euo pipefail

    API_KEY_FILE="${anthropicApiKeyFile}"

    if [ ! -f "$API_KEY_FILE" ]; then
      echo "Error: Anthropic API key file not found: $API_KEY_FILE"
      exit 1
    fi

    API_KEY=$(${pkgs.coreutils}/bin/cat "$API_KEY_FILE")
    if [ -z "$API_KEY" ]; then
      echo "Error: Anthropic API key file is empty: $API_KEY_FILE"
      exit 1
    fi

    export ANTHROPIC_API_KEY="$API_KEY"
    exec ${pkgs.clawdbot-gateway}/bin/clawdbot gateway --port 18789
  '';
in {
  # Custom clawdbot configuration (bypassing the buggy official module)

  home = {
    packages = [pkgs.clawdbot-gateway];

    # Set CLAWDBOT_BUNDLED_PLUGINS_DIR for shell sessions so the CLI finds plugins
    sessionVariables.CLAWDBOT_BUNDLED_PLUGINS_DIR = "${clawdbotSource}/extensions";

    # Initialize clawdbot workspace and config
    # ALWAYS update the config to ensure workspace path is correct
    # Copy template files only if they don't exist (preserves user customizations)
    activation.clawdbotSetup = config.lib.dag.entryAfter ["writeBoundary"] ''
      ${pkgs.coreutils}/bin/mkdir -p "$HOME/.clawdbot"
      ${pkgs.coreutils}/bin/mkdir -p "$HOME/clawd"

      # Always write config to ensure workspace path is correct
      echo '${configJson}' > "$HOME/.clawdbot/clawdbot.json"
      ${pkgs.coreutils}/bin/chmod 600 "$HOME/.clawdbot/clawdbot.json"

      # Copy workspace templates only if they don't exist
      for template in AGENTS.md SOUL.md TOOLS.md IDENTITY.md USER.md HEARTBEAT.md BOOTSTRAP.md; do
        if [ ! -f "$HOME/clawd/$template" ]; then
          ${pkgs.coreutils}/bin/cp "${clawdbotSource}/docs/reference/templates/$template" "$HOME/clawd/$template"
        fi
      done
    '';
  };

  # Systemd service
  systemd.user.services.clawdbot-gateway = {
    Unit.Description = "Clawdbot gateway";
    Service = {
      ExecStart = "${gatewayWrapper}";
      WorkingDirectory = "${config.home.homeDirectory}/.clawdbot";
      Restart = "always";
      RestartSec = "1s";
      Environment = [
        "HOME=${config.home.homeDirectory}"
        "CLAWDBOT_CONFIG_PATH=${config.home.homeDirectory}/.clawdbot/clawdbot.json"
        "CLAWDBOT_STATE_DIR=${config.home.homeDirectory}/.clawdbot"
        "CLAWDBOT_BUNDLED_PLUGINS_DIR=${clawdbotSource}/extensions"
      ];
    };
    Install.WantedBy = ["default.target"];
  };
}
