mod gt 'just/gt.just'

mode := "test"
user := "dan"


fmt:
  nix fmt

nixos-rebuild host:
  nixos-rebuild --cores 12 --max-jobs 6 --flake .#{{host}} {{mode}} --log-format internal-json -v |& nom --json

set positional-arguments

home host *args='':
  unbuffer home-manager --cores 12 --max-jobs 6 --flake .#{{user}}@{{host}} "${@:2}" |& grep -v '^$' | nom
