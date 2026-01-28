_: {
  sops = {
    defaultSopsFile = ./secrets.sops.yaml;
    gnupg.home = "/home/dan/.gnupg";
    secrets = {
      # each secret references a key in the secrets.sops.yaml file
      CLAUDE_CODE_TOKEN = {};
      OPENAI_API_KEY = {};
      TESTPYPI_TOKEN = {};
      # Per-host Telegram bot tokens for clawdbot
      CLAWDBOT_TELEGRAM_TOKEN_DANPC = {};
      CLAWDBOT_TELEGRAM_TOKEN_FRAMNIX = {};
    };
  };
}
