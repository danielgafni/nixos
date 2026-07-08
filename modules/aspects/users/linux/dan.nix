{
  den,
  inputs,
  lib,
  ...
}: let
  mkWaystt = pkgs: let
    crane = inputs.crane.mkLib pkgs;
    src = inputs.waystt;
    commonArgs = {
      inherit src;
      pname = "waystt";
      strictDeps = true;
      nativeBuildInputs = with pkgs; [pkg-config cmake git];
      buildInputs = with pkgs; [alsa-lib pipewire openssl llvmPackages.libclang];
      LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
    };
    cargoArtifacts = crane.buildDepsOnly commonArgs;
  in
    crane.buildPackage (commonArgs // {inherit cargoArtifacts;});
in {
  den.aspects.dan-linux = {
    includes = [
      den.aspects.dan
      # Linux shared HM features
      den.aspects.shared-hm-linux
      # Linux-specific dan features
      den.aspects.hyprpaper
      den.aspects.dan-sops
      den.aspects.gpg-linux
      den.aspects.keyboards
      den.aspects.neovim-linux
      den.aspects.zed-linux
      den.aspects.content-linux
    ];
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      # bitwarden-desktop pins EOL electron 39 (still the case on nixos-unstable as of 2026-07)
      nixpkgs.config.permittedInsecurePackages = [
        "electron-39.8.10"
      ];
      programs = {
        nebius-cli.enable = true;
        waystt = {
          enable = true;
          package = mkWaystt pkgs;
          settings = {
            TRANSCRIPTION_PROVIDER = "openai";
          };
          openaiKeyFile = "/home/dan/.config/sops-nix/secrets/OPENAI_API_KEY";
        };
      };
      home.packages = with pkgs; [
        yubioath-flutter
        inputs.dagger.packages.${pkgs.stdenv.hostPlatform.system}.dagger
        inputs.rip.packages.${pkgs.stdenv.hostPlatform.system}.default
        libnotify
        hyprpicker
        grim
        slurp
        wev
        wl-clipboard
        font-manager
        alacritty
        dconf
        pipewire
        wireplumber
        strace
        fastfetch
        signal-desktop
        element-desktop
        discord
        slack
        zoom-us
        karere
        google-chrome
        rustlings
        mpv
        keepassxc
        bitwarden-desktop
        vlc
        xarchiver
        wireguard-ui
      ];
    };
  };
}
