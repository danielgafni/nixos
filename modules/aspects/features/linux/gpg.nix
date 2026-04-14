_: {
  den.aspects.gpg-linux = {
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      services.gpg-agent = {
        pinentry.package = lib.mkForce pkgs.pinentry-gtk2;
      };
    };
  };
}
