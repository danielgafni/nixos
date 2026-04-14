{den, ...}: {
  den.aspects.chrome-hidraw = {
    nixos = _: {
      users.groups.plugdev = {};

      services.udev.extraRules = ''
        # NuPhy keyboards - Allow user access for WebHID/VIA keyboard control
        SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="19f5", MODE="0660", GROUP="plugdev", TAG+="uaccess"
        KERNEL=="hidraw*", ATTRS{idVendor}=="19f5", MODE="0660", GROUP="plugdev", TAG+="uaccess"
      '';
    };
  };
}
