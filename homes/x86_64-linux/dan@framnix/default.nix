{pkgs, ...}: {
  imports = [
    ../../common
  ];

  home = {
    packages = with pkgs; [
      home-manager
    ];
  };

  programs = {
    git = {
      enable = true;
      userName = "danielgafni";
      userEmail = "danielgafni16@gmail.com";
      signing = {
        key = "7B0740201D518DB134D5C75AB8D13360DED17662";
        signByDefault = true;
      };
    };
    vscode.enable = true;
    neovim.enable = true;
  };
} 