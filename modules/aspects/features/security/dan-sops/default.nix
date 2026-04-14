_: {
  den.aspects.dan-sops = {
    homeManager = {config, ...}: {
      sops = {
        defaultSopsFile = ./secrets.sops.yaml;
        gnupg.home = "${config.home.homeDirectory}/.gnupg";
        secrets = {
          CLAUDE_CODE_TOKEN = {};
          OPENAI_API_KEY = {};
          TESTPYPI_TOKEN = {};
        };
      };
    };
  };
}
