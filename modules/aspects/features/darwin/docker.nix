_: {
  den.aspects.docker-mac = {
    darwin = {
      pkgs,
      config,
      ...
    }: {
      environment.systemPackages = with pkgs; [
        docker
        docker-compose
        colima
      ];

      # Point docker CLI at colima's socket
      environment.variables.DOCKER_HOST = "unix:///Users/${config.system.primaryUser}/.colima/default/docker.sock";

      launchd.user.agents.colima = {
        # vz (Virtualization.framework) instead of the default qemu backend:
        # nixpkgs qemu 11.0.0 crashes at startup on macOS 26 (HVF assertion
        # on HV_SYS_REG_SMCR_EL1), and vz is faster anyway. Switching an
        # existing qemu-created VM requires `colima delete` first.
        command = "${pkgs.colima}/bin/colima start --foreground --vm-type vz --memory 16 --root-disk 500";
        path = [pkgs.docker pkgs.colima "/usr/bin" "/bin" "/usr/sbin"];
        serviceConfig = {
          Label = "com.github.abiosoft.colima";
          RunAtLoad = true;
          KeepAlive = true;
          StandardOutPath = "/tmp/colima.stdout.log";
          StandardErrorPath = "/tmp/colima.stderr.log";
        };
      };
    };
  };
}
