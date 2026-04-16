{
  den,
  inputs,
  ...
}: {
  den.aspects.dan = {
    includes = [
      den.provides.define-user
      den.provides.primary-user
      # Shared HM features (cross-platform)
      den.aspects.shared-hm
      den.aspects.yubikey
      den.aspects.gpg
      # Editors
      den.aspects.neovim
      den.aspects.zed
      den.aspects.helix
      den.aspects.cursor
      # Dev tools
      den.aspects.krewfile
      den.aspects.content
    ];
    # NixOS-specific user settings (nixos class naturally scoped)
    nixos.users.users.dan = {
      initialPassword = "pw123";
      extraGroups = [
        "wheel"
        "docker"
        "video"
        "networkmanager"
        "plugdev"
        "input"
      ];
    };
    homeManager = {pkgs, ...}: {
      programs = {
        bun.enable = true;
        # _1password-shell-plugins = {
        #   enable = true;
        #   plugins = with pkgs; [gh awscli2 cachix];
        # };
      };

      home.packages = with pkgs; [
        yubikey-manager
        kubectl
        kubeseal
        sops
        age
        (pkgs.wrapHelm pkgs.kubernetes-helm {plugins = [];})
        (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])
        awscli2
        opentofu
        terragrunt
        pulumi-bin
        argocd
        kind
        devspace
        docker
        graphviz
        ripgrep
        fd
        dust
        dua
        nix-output-monitor
        comma
        statix
        ruplacer
        curl
        wget
        eza
        pfetch
        neofetch
        pre-commit
        just
        sad
        expect
        inputs.devenv.packages.${pkgs.stdenv.hostPlatform.system}.devenv
        vim
        obsidian
        pyright
        ruff
        uv
        graphite-cli
        cargo
        rustc
        yarn
        gcc
        cmake
        rust-analyzer
        nodejs
        telegram-desktop
        discord
      ];
    };
  };
}
