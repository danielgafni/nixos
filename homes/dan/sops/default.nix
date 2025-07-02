{user, ...}: {
  sops = {
    defaultSopsFile = ./secrets.sops.yaml;
    gnupg.home = "/home/dan/.gnupg";
    secrets = {
      # each secret references a key in the secrets.sops.yaml file
      CLAUDE_CODE_TOKEN = {};
    };
  };
}
