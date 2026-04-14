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
        command = "${pkgs.colima}/bin/colima start --foreground --disk 500";
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
