{
  den,
  inputs,
  ...
}: {
  den.aspects.DanPC = {
    includes = [
      den.provides.hostname
      # NixOS system
      den.aspects.nixos-system
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
      imports = [(modulesPath + "/installer/scan/not-detected.nix")];

      nixpkgs.overlays = [inputs.nixpkgs-wayland.overlay];
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      users.extraGroups.docker.members = ["dan"];

      # Hardware
      boot = {
        initrd.availableKernelModules = [
          "nvme"
          "xhci_pci"
          "ahci"
          "usbhid"
          "usb_storage"
          "sd_mod"
          "nvidia"
          "nvidia_modeset"
          "nvidia_uvm"
          "nvidia_drm"
        ];
        initrd.kernelModules = ["nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm"];
        kernelModules = ["kvm-amd"];
        kernelParams = [
          "nvidia_drm.fbdev=1"
          "nvidia_drm.modeset=1"
        ];
        extraModulePackages = [];
      };

      fileSystems = {
        "/" = {
          device = "/dev/disk/by-label/NIXROOT";
          fsType = "btrfs";
          options = ["subvol=root"];
        };
        "/home" = {
          device = "/dev/disk/by-label/NIXROOT";
          fsType = "btrfs";
          options = ["subvol=home"];
        };
        "/nix" = {
          device = "/dev/disk/by-label/NIXROOT";
          fsType = "btrfs";
          options = ["subvol=nix" "noatime"];
        };
        "/boot" = {
          device = "/dev/disk/by-label/NIXBOOT";
          fsType = "vfat";
        };
      };

      networking.useDHCP = lib.mkDefault true;
      hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

      # GPU
      services.xserver.videoDrivers = ["nvidia"];
      hardware = {
        nvidia-container-toolkit.enable = true;
        nvidia = {
          modesetting.enable = true;
          powerManagement.enable = false;
          powerManagement.finegrained = false;
          open = false;
          nvidiaSettings = true;
          package = config.boot.kernelPackages.nvidiaPackages.production;
        };
        graphics = {
          enable = true;
          enable32Bit = true; # required by nvidia docker
        };
      };

      swapDevices = [
        {
          device = "/swapfile";
          size = 32 * 1024; # 32GB
        }
      ];

      system.stateVersion = "23.11";
    };
  };
}
