mode := "test"
user := "dan"


fmt:
  nix fmt

nixos-rebuild host:
  sudo nixos-rebuild --flake .#{{host}} {{mode}}

set positional-arguments

home host *args='':
  home-manager --flake .#{{user}}@{{host}} "${@:2}"

