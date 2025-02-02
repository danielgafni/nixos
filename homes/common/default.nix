{pkgs, ...}: {
  # Common home-manager configuration shared between all users
  home = {
    stateVersion = "23.11";

    packages = with pkgs; [
      firefox
      git
      htop
      ripgrep
      fd
    ];
  };

  programs = {
    bash = {
      enable = true;
      shellAliases = {
        ll = "ls -l";
        update = "sudo nixos-rebuild switch";
      };
    };

    git = {
      enable = true;
      delta.enable = true;
    };
  };
}
