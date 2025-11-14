{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.krewfile.homeManagerModules.krewfile
  ];

  programs.krewfile = {
    enable = true;
    krewPackage = pkgs.krew;
    indexes = {};
    plugins = [
      "krew"
      "ray"
      "modify-secret"
      "oidc-login"
    ];
  };
}
