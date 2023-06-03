home-manager --flake . switch || exit 1
sudo nixos-rebuild --flake . switch

