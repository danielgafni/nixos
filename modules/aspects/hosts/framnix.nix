{
  den,
  inputs,
  ...
}: {
  den.aspects.framnix = {
    includes = [
      den.provides.hostname
      # NixOS system
      den.aspects.nixos-system
      den.aspects.bluetooth
      den.aspects."1password"
      den.aspects.yubikey
      den.aspects.secrets
      den.aspects.chrome-hidraw
    ];
    nixos = {
      config,
      pkgs,
      lib,
      modulesPath,
      ...
    }: {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
        inputs.nixos-hardware.nixosModules.framework-12th-gen-intel
      ];

      nixpkgs.overlays = [inputs.nixpkgs-wayland.overlay];
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      users.extraGroups.docker.members = ["dan"];

      # Hardware
      boot = {
        loader.grub.device = "/dev/nvme0n1";
        initrd.availableKernelModules = ["xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod"];
        initrd.kernelModules = [];
        kernelModules = ["kvm-intel"];
        # Framework Laptops have auto brightness detection which has to be disabled
        # otherwise the brightness keys don't work
        blacklistedKernelModules = ["hid_sensor_hub"];
        extraModulePackages = [];
      };

      fileSystems."/" = {
        device = "/dev/disk/by-label/NIXROOT";
        fsType = "ext4";
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-label/NIXBOOT";
        fsType = "vfat";
      };

      swapDevices = [];

      networking.useDHCP = lib.mkDefault true;
      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
      powerManagement.powertop.enable = true;

      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [libvdpau-va-gl];
      };

      services = {
        # battery module in hyprpanel
        gvfs.enable = true;
        power-profiles-daemon.enable = true;
        upower.enable = true;
        fwupd = {
          enable = true;
          # https://github.com/NixOS/nixos-hardware/tree/master/framework/13-inch/13th-gen-intel#getting-the-fingerprint-sensor-to-work
          package =
            (import (builtins.fetchTarball {
                url = "https://github.com/NixOS/nixpkgs/archive/bb2009ca185d97813e75736c2b8d1d8bb81bde05.tar.gz";
                sha256 = "sha256:003qcrsq5g5lggfrpq31gcvj82lb065xvr7bpfa8ddsw8x4dnysk";
              }) {
                inherit (pkgs) system;
              })
            .fwupd;
        };
      };

      system.stateVersion = "22.11";
    };
  };
}
