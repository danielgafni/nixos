{inputs, ...}: {
  home.packages = [
    inputs.zed.packages.x86_64-linux.zed-editor
  ];

  xdg.configFile."zed/settings.json" = {
    source = ./settings.json;
  };
}
# "ssh_connections": [
#       {
#         "host": "devbox",
#         "projects": [
#           {
#             "paths": [
#               "~/dagster"
#             ]
#           },
#           {
#             "paths": [
#               "~/dagster-ray"
#             ]
#           }
#         ]
#       }
#     ]

