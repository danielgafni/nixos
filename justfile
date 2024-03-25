mode := "test"
user := "dan"


fmt:
  nix fmt

nixos-rebuild host:
  sudo nixos-rebuild --log-format internal-json -v --flake .#{{host}} {{mode}} |& nom --json

set positional-arguments

home host *args='':
  home-manager --flake .#{{user}}@{{host}} "${@:2}"

