mode := "test"
user := "dan"


fmt:
  nix fmt

nixos-rebuild host:
  nixos-rebuild --cores 12 --max-jobs 4 --flake .#{{host}} {{mode}} --log-format internal-json -v |& nom --json

set positional-arguments

home host *args='':
  home-manager --flake .#{{user}}@{{host}} "${@:2}" |& nom

