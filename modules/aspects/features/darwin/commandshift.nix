# CommandShift — switches macOS input source with Windows-style shortcuts
# (default: Cmd+Shift). Pure userspace Qt app, needs only Accessibility
# permission. Built from source via the `commandshift` flake input.
{inputs, ...}: let
  mkCommandShift = pkgs:
    pkgs.stdenv.mkDerivation {
      pname = "commandshift";
      version = inputs.commandshift.shortRev or "unstable";

      src = inputs.commandshift;
      sourceRoot = "source/src";

      nativeBuildInputs = with pkgs.qt6; [qmake wrapQtAppsHook];
      buildInputs = [pkgs.qt6.qtbase];

      # Upstream pins QMAKE_APPLE_DEVICE_ARCHS to "x86_64 arm64" for universal
      # builds; strip it so qmake builds for the host arch only (we don't have
      # cross-arch Qt libs in nixpkgs).
      postPatch = ''
        sed -i '/QMAKE_APPLE_DEVICE_ARCHS/d' CommandShift.pro
      '';

      installPhase = ''
        runHook preInstall
        mkdir -p $out/Applications
        cp -r CommandShift.app $out/Applications/
        runHook postInstall
      '';

      meta = with pkgs.lib; {
        description = "Switch macOS input source with Windows-style shortcuts";
        homepage = "https://github.com/VasylBaran/CommandShift";
        license = licenses.gpl3Only;
        platforms = platforms.darwin;
      };
    };
in {
  den.aspects.commandshift = {
    homeManager = {pkgs, ...}: {
      programs.commandshift = {
        enable = true;
        package = mkCommandShift pkgs;
      };
    };
  };
}
