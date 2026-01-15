_: {
  # Create the plugdev group for device access
  users.groups.plugdev = {};

  services.udev.extraRules = ''
    # NuPhy keyboards - Allow user access for WebHID/VIA keyboard control
    # Vendor ID 19f5 matches all NuPhy devices
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="19f5", MODE="0660", GROUP="plugdev", TAG+="uaccess"
    KERNEL=="hidraw*", ATTRS{idVendor}=="19f5", MODE="0660", GROUP="plugdev", TAG+="uaccess"
  '';
}
