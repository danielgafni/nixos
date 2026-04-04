{
  den,
  inputs,
  lib,
  ...
}: let
  mkStax = pkgs: let
    crane = inputs.crane.mkLib pkgs;
    src = inputs.stax;
    commonArgs = {
      inherit src;
      pname = "stax";
      strictDeps = true;
      nativeBuildInputs = with pkgs; [pkg-config cmake perl];
      buildInputs = with pkgs; [zlib];
    };
    cargoArtifacts = crane.buildDepsOnly commonArgs;
  in
    crane.buildPackage (commonArgs
      // {
        inherit cargoArtifacts;
        doCheck = false;
      });

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
      programs = {
        nebius-cli.enable = true;
        stax = {
          enable = true;
          package = mkStax pkgs;
        };
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
        neofetch
        signal-desktop
        element-desktop
        slack
        zoom-us
        wasistlos
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
