{pkgs, ...}: {
  environment.systemPackages = [pkgs._1password-gui-beta];
  programs = {
    _1password = {
      enable = true;
    };
    _1password-gui = {
      package = pkgs._1password-gui-beta;
      polkitPolicyOwners = ["dan"];
    };
  };
  environment.etc = {
    "1password/custom_allowed_browsers" = {
      text = ''
        google-chrome-stable
        google-chromeo
        firefox
      '';
      mode = "0755";
    };
  };
}
