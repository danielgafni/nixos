{
  lib,
  pkgs,
  ...
}: {
  # Common system configuration shared between all hosts
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
    };
  };

  # Set your time zone
  time.timeZone = "Europe/Moscow"; # Adjust this to your timezone

  # Select internationalisation properties
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable sound
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Basic system packages
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
  ];

  # User configurations
  users.users = {
    dan = {
      isNormalUser = true;
      initialPassword = "pw123";
      extraGroups = ["wheel" "docker" "video" "networkmanager"];
    };

    underdel = {
      isNormalUser = true;
      initialPassword = "pw123";
      extraGroups = ["video" "networkmanager"];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken.
  system.stateVersion = "23.11"; # Do not change this
}
