{lib, ...}: {
  imports = [
    ../common
    ./hardware-configuration.nix
  ];

  networking.hostName = "DanPC";

  # Add DanPC specific configurations here
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
}
