{
  inputs,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # Nix language servers
    hyprpanel # awailable via overlay

    # optional deps
    gpustat
    gpu-screen-recorder
    hyprpicker
    hyprsunset
    hypridle
    btop
    matugen
    swww
  ];
}
