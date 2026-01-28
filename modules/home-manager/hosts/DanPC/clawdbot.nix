# DanPC-specific clawdbot configuration
{
  config,
  lib,
  ...
}: {
  imports = [
    ../../programs/clawdbot/base.nix
  ];

  programs.clawdbot.instances.default = lib.mkMerge [
    config.programs.clawdbot.baseConfig
    {
      # DanPC-specific: Telegram bot token
      providers.telegram = {
        enable = true;
        botTokenFile = config.sops.secrets.CLAWDBOT_TELEGRAM_TOKEN_DANPC.path;
        allowFrom = [301446776];
      };
    }
  ];
}
