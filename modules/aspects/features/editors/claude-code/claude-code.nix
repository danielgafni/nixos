{den, ...}: {
  den.aspects.claude-code = {
    homeManager = {
      config,
      lib,
      ...
    }: let
      # The native installer (~/.local/bin/claude) stays the source of truth for
      # the binary itself — it auto-updates and runs ahead of nixpkgs. Nix owns
      # the *configuration* only, so `package = null`.
      claudeBin = "${config.home.homeDirectory}/.local/bin/claude";

      # Global MCP servers. The native binary reads these from ~/.claude.json
      # (user scope), which home-manager cannot own as a plain file. Instead we
      # bake idempotent `claude mcp add` commands into activation. The servers
      # themselves are fetched at runtime (uvx/npx), so they stay latest.
      mcpServers = {
        mcp-nixos = ["uvx" "mcp-nixos"];
        kubernetes = ["npx" "-y" "mcp-server-kubernetes"];
      };
      registerMcp = name: argv: ''
        run mcp remove -s user ${name}
        run mcp add -s user ${name} -- ${lib.escapeShellArgs argv}
      '';
    in {
      programs.claude-code = {
        enable = true;
        package = null; # keep the native, auto-updating install

        # Global context: ~/.claude/CLAUDE.md
        context = ../agent-context/AGENTS.md;

        # ~/.claude/settings.json (declarative — runtime toggles won't persist)
        settings = {
          model = "claude-opus-4-8[1m]";
          effortLevel = "high";
          tui = "fullscreen";
          skipDangerousModePermissionPrompt = true;

          enabledPlugins = {
            "pyright-lsp@claude-plugins-official" = true;
            "codex@openai-codex" = true;
          };

          extraKnownMarketplaces = {
            pulumi-agent-skills.source = {
              source = "github";
              repo = "pulumi/agent-skills";
            };
            openai-codex.source = {
              source = "github";
              repo = "openai/codex-plugin-cc";
            };
          };
        };

        # Declarative custom skills / agents / commands live here. Each entry is
        # inline markdown or a path. Example (uncomment to use):
        #
        # skills.my-skill = ./skills/my-skill/SKILL.md;
        # agents.reviewer = ./agents/reviewer.md;
        # commands.deploy = ./commands/deploy.md;
      };

      # Register global MCP servers idempotently on every home activation.
      home.activation.claudeMcpServers = lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [ -x "${claudeBin}" ]; then
          run() { "${claudeBin}" "$@" >/dev/null 2>&1 || true; }
          ${lib.concatStrings (lib.mapAttrsToList registerMcp mcpServers)}
        fi
      '';
    };
  };
}
