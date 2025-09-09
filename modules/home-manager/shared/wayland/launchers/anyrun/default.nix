{
  inputs,
  pkgs,
  ...
}: {
  programs = {
    anyrun = {
      enable = true;
      config = {
        # layer = "top";
        closeOnClick = true;
        showResultsImmediately = true;
        y = {fraction = 0.3;};
        # height = { fraction = 0.3; };
        # width = { fraction = 0.3; };
        plugins = [
          # An array of all the plugins you want, which either can be paths to the .so files, or their packages
          "${pkgs.anyrun}/lib/libapplications.so"
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
