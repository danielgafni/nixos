{inputs, ...}: {
  programs.zed-editor = {
    enable = true;
    package = inputs.zed.packages.x86_64-linux.zed-editor;
    # read settings.json
    userSettings = builtins.fromJSON (builtins.readFile ./settings.json);
    extensions = [
      "catppuccin-blur"
      "nix"
      "dockerfile"
      "docker-compose"
      "git-firefly"
    ];
  };
}
