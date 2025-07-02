{
  inputs,
  pkgs,
  ...
}: {
  programs = {
    anyrun = {
      enable = true;
      package = inputs.anyrun.packages.${pkgs.system}.anyrun;
      config = {
        # layer = "top";
        closeOnClick = true;
        showResultsImmediately = true;
        y = {fraction = 0.3;};
        # height = { fraction = 0.3; };
        # width = { fraction = 0.3; };
        plugins = [
          # An array of all the plugins you want, which either can be paths to the .so files, or their packages
          inputs.anyrun.packages.${pkgs.system}.applications
          # file search
          # inputs.anyrun.packages.${pkgs.system}.kidex
          # inputs.anyrun.packages.${pkgs.system}.websearch
          # "${inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins}/lib/kidex"
        ];
      };
      extraCss = builtins.readFile ./style.css;
    };
  };
}
