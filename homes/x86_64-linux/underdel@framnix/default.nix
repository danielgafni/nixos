{pkgs, ...}: {
  imports = [
    ../../common
  ];

  home = {
    packages = with pkgs; [
      home-manager
    ];
  };

  programs.git = {
    enable = true;
    userName = "Lina Gafni";
    userEmail = "linagafni@gmail.com";
  };

  # User-specific settings
  programs.firefox.enable = true;
}
