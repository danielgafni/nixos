{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.nebius-cli;

  package = pkgs.callPackage (
    {
      lib,
      stdenv,
      fetchurl,
      makeWrapper,
      installShellFiles,
    }: let
      version = "0.12.73"; # to get the latest version: curl https://storage.eu-north1.nebius.cloud/cli/release/stable
      hash = "sha256-DvGiAMxUPNZj7AF3s1FDEpA1jCMlrKezBNitJ6zhUEI=";
      os =
        if stdenv.isDarwin
        then "darwin"
        else "linux";
      arch =
        if stdenv.isAarch64
        then "arm64"
        else "x86_64";
      pname = "nebius-cli";

      storageBase = "https://storage.eu-north1.nebius.cloud/cli";
    in
      stdenv.mkDerivation {
        inherit pname;
        inherit version;

        src = fetchurl {
          urls = [
            "${storageBase}/release/${version}/${os}/${arch}/nebius"
          ];
          inherit hash;
        };

        nativeBuildInputs = [
          makeWrapper
          installShellFiles
        ];

        dontUnpack = true;
        dontBuild = true;

        installPhase = ''
          runHook preInstall

          # Create directories
          mkdir -p $out/bin

          # Install binary
          install -m755 $src $out/bin/nebius

          runHook postInstall
        '';

        postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
          # completions can be generated like this: $out/bin/nebius completions zsh

          $out/bin/nebius completion zsh > completion.zsh
          $out/bin/nebius completion bash > completion.bash
          $out/bin/nebius completion fish > completion.fish

          installShellCompletion --cmd nebius completion.zsh completion.bash completion.fish

        '';

        doInstallCheck = true;
        installCheckPhase = ''
          $out/bin/nebius version
        '';

        meta = with lib; {
          description = "Command-line interface for Nebius Cloud Platform";
          homepage = "https://docs.nebius.com/cli";
          platforms = platforms.unix;
          sourceProvenance = with sourceTypes; [binaryNativeCode];
          license = licenses.unfree; # Adjust if there's a specific license
          maintainers = []; # Add maintainers if needed
          programs = with pkgs; [nebius-cli];
        };
      }
  ) {};
in {
  options.programs.nebius-cli = {
    enable = mkEnableOption "Nebius CLI";

    package = mkOption {
      type = types.package;
      default = package;
      description = "The Nebius CLI package to use.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];
  };
}
