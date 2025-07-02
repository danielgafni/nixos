{
  userConfig,
  pkgs,
  ...
}: {
  programs.rbw = {
    enable = true;
    settings = {
      inherit (userConfig) email;
      pinentry = pkgs.pinentry-gtk2;
    };
  };
}
