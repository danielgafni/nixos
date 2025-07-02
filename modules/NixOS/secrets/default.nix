{pkgs, ...}: {
  services.passSecretService.enable = true;
  environment.systemPackages = with pkgs; [
    keepassxc
  ];
  sops = {
    gnupg.home = "/var/lib/sops";
  };
}
