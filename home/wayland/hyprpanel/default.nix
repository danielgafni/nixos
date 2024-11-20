{
  inputs,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # Nix language servers
    hyprpanel # awailable via overlay
  ];
}
