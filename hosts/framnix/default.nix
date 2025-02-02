{lib, ...}: {
  imports = [
    ../common
    ./hardware-configuration.nix
  ];

  networking.hostName = "framnix";

  # Add framnix specific configurations here
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
}
