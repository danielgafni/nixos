_: {
  programs.gpg = {
    enable = true;
    publicKeys = [
      {
        source = ./yubikey.pgp;
        trust = 5;
      }
      {
        source = ./yubikey-old.pgp;
        trust = 5;
      }
    ];
  };
}
