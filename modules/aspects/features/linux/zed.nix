{inputs, ...}: {
  den.aspects.zed-linux = {
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      programs.zed-editor.package = lib.mkForce inputs.chaotic.packages.${pkgs.stdenv.hostPlatform.system}.zed-editor_git;
    };
  };
}
