#!bash

mode="${1:-test}"

if [ $mode == "test" ]; then
    echo "Building in test mode, will not add ad bootloader entry"
elif [ $mode == "install" ]; then
    echo "Building in switch mode, will add a new bootloader entry!"
else
    echo "Unknown mode ${mode}"
    exit 1
fi

home-manager --flake . switch || exit 1
echo "Running: nixos-rebuild --flake . $mode"
sudo nixos-rebuild --flake . $mode
