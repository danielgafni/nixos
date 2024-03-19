mode := "test"
user := "dan"


fmt:
  nix fmt

nixos-rebuild host:
  sudo nixos-rebuild --flake .#{{host}} {{mode}}


home-rebuild host:
  home-manager --flake .#{{user}}@{{host}} switch
