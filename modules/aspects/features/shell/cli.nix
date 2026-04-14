{
  den,
  inputs,
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
in {
  den.aspects = {
    cli = {
      homeManager = {
        config,
        pkgs,
        ...
      }: let
        ud = config.my.userConfig;
      in {
        programs = {
          bat = {
            enable = true;
            config.pager = "less -FR";
            extraPackages = with pkgs.bat-extras; [batdiff batman batgrep batwatch];
          };
          yazi = {
            enable = true;
            enableZshIntegration = true;
            shellWrapperName = "y";
          };
          zellij = {
            enable = true;
            enableBashIntegration = false;
            enableZshIntegration = false;
          };
          zoxide = {
            enable = true;
            enableZshIntegration = true;
          };
          gh = {
            enable = true;
            settings = {
              git_protocol = "ssh";
            };
          };
          gh-dash = {
            enable = true;
          };
          k9s = {
            enable = true;
          };
          rbw = {
            enable = true;
            settings = {
              email = ud.email or "danielgafni16@gmail.com";
            };
          };
          stax = {
            enable = true;
            package = mkStax pkgs;
          };
        };
        home.packages = [pkgs._1password-cli];
      };
    };
    cli-darwin = {
      homeManager = {pkgs, ...}: {
        programs.rbw.settings.pinentry = pkgs.pinentry_mac;
      };
    };
    cli-linux = {
      homeManager = {pkgs, ...}: {
        programs.rbw.settings.pinentry = pkgs.pinentry-gtk2;
      };
    };
  };
}
