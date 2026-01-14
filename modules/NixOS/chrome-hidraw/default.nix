_: {
  # Create the plugdev group
  users.groups.plugdev = {};

  services.udev.extraRules = ''
    # Allow user access to /dev/hidraw2 for WebHID
    # originally added for the VIA keyboard control web app
    KERNEL=="hidraw2", MODE="0660", GROUP="plugdev", TAG+="uaccess"
  '';
}
