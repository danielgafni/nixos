_: {
  den.aspects.gpg-darwin = {
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      services.gpg-agent.pinentry.package = lib.mkForce pkgs.pinentry_mac;
    };
  };
}
