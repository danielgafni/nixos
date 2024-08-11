_: {
  programs.gpg = {
    enable = true;
    publicKeys = [
      {
        source = ./yubikey.pgp;
        trust = 5;
      }
    ];
  };
}
