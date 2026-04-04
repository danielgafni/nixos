# Shared home-manager features included by user aspects.
{den, ...}: {
  den.aspects.shared-hm = {
    includes = [
      den.aspects.base
      den.aspects.shell
      den.aspects.fonts
      den.aspects.git
      den.aspects.ssh
      den.aspects.terminals
      den.aspects.cli
      den.aspects.nix-tools
    ];
  };
}
