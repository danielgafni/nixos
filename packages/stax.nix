{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.programs.stax;

  crane = inputs.crane.mkLib pkgs;

  src = inputs.stax;

  commonArgs = {
    inherit src;
    pname = "stax";
    strictDeps = true;

    nativeBuildInputs = with pkgs; [
      pkg-config
      cmake
      perl
    ];

    buildInputs = with pkgs; [
      zlib
    ];
  };

  cargoArtifacts = crane.buildDepsOnly commonArgs;

  stax = crane.buildPackage (commonArgs
    // {
      inherit cargoArtifacts;

      # Tests require git CLI and CA certificates unavailable in the Nix sandbox
      doCheck = false;

      meta = {
        description = "Fast stacked Git branches and PRs";
        homepage = "https://github.com/cesarferreira/stax";
        license = licenses.mit;
        platforms = platforms.linux;
        maintainers = [];
      };
    });
in {
  options.programs.stax = {
    enable = mkEnableOption "stax - fast stacked Git branches and PRs";

    package = mkOption {
      type = types.package;
      default = stax;
      description = "The stax package to use.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];
  };
}
