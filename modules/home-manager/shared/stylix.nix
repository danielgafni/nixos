# typically everything is styled with catppuccin-nix, but some programs are missing there (e.g. GTK) so we use Stylix for them instead
{inputs, ...}: {
  stylix = {
    enable = true;
    autoEnable = false; # targets have to be enabled individually
    base16Scheme = ./base16-catppuccin-mocha.yaml;
    targets.gtk = {
      enable = true;
    };
  };
}
