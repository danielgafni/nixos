{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.aviator-cli;

  # Aviator CLI (stacked PRs) — not in nixpkgs
  package = pkgs.buildGo126Module rec {
    pname = "av";
    version = "0.1.45";

    src = pkgs.fetchFromGitHub {
      owner = "aviator-co";
      repo = "av";
      tag = "v${version}";
      hash = "sha256-ndB4kLLNHtp0WcBmGw4J+WD0eU4X3AtzThM/KXiaVZE=";
    };

    vendorHash = "sha256-ay7MKobJaLTE9pQQubimDoyIjMi184CU3P6wMhQkGbQ=";

    subPackages = ["cmd/av"];

    ldflags = [
      "-s"
      "-w"
      "-X github.com/aviator-co/av/internal/config.Version=v${version}"
    ];

    nativeBuildInputs = [pkgs.installShellFiles];

    postInstall = ''
      installShellCompletion --cmd av \
        --bash <($out/bin/av completion bash) \
        --zsh <($out/bin/av completion zsh) \
        --fish <($out/bin/av completion fish)
    '';

    meta = {
      description = "Aviator CLI for stacked pull requests";
      homepage = "https://github.com/aviator-co/av";
      mainProgram = "av";
    };
  };
in {
  options.programs.aviator-cli = {
    enable = mkEnableOption "Aviator CLI (stacked PRs)";

    package = mkOption {
      type = types.package;
      default = package;
      description = "The Aviator CLI package to use.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];
  };
}
