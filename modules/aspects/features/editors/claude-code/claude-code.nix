{den, ...}: {
  den.aspects.claude-code = {
    homeManager = {
      config,
      lib,
      pkgs,
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
        run --silence "${claudeBin}" mcp remove -s user ${name} || true
        run --silence "${claudeBin}" mcp add -s user ${name} -- ${lib.escapeShellArgs argv} || true
      '';

      # ~/.claude/settings.json must stay writable: /model, /effort, /config etc.
      # persist to it at runtime. So instead of a read-only store symlink, these
      # declared settings are deep-merged over the live file on every activation
      # (declared keys win; runtime-only keys survive until they're declared).
      settings = {
        model = "claude-opus-5-5[1m]";
        effortLevel = "high";
        tui = "fullscreen";
        skipDangerousModePermissionPrompt = true;

        enabledPlugins = {
          "pyright-lsp@claude-plugins-official" = true;
          "codex@openai-codex" = true;
          "avoid-ai-writing@conorbronsdon-skills" = true;
        };

        extraKnownMarketplaces = {
          conorbronsdon-skills.source = {
            source = "github";
            repo = "conorbronsdon/avoid-ai-writing";
          };
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
      settingsFile = (pkgs.formats.json {}).generate "claude-code-settings.json" (
        settings // {"$schema" = "https://json.schemastore.org/claude-code-settings.json";}
      );
    in {
      programs.claude-code = {
        enable = true;
        package = null; # keep the native, auto-updating install

        # Global context: ~/.claude/CLAUDE.md
        context = ../agent-context/AGENTS.md;

        # Declarative custom skills / agents / commands live here. Each entry is
        # inline markdown or a path. Example (uncomment to use):
        #
        # skills.my-skill = ./skills/my-skill/SKILL.md;
        # agents.reviewer = ./agents/reviewer.md;
        # commands.deploy = ./commands/deploy.md;
      };

      # Leaves Nix owned last time (tracked in $last) but no longer declares are
      # pruned, so removing a key here actually removes it. Corrupt JSON is moved
      # aside rather than failing the whole switch.
      home.activation.claudeSettings = lib.hm.dag.entryAfter ["linkGeneration"] ''
        jq=${lib.getExe pkgs.jq}
        settings="${config.programs.claude-code.configDir}/settings.json"
        last="${config.programs.claude-code.configDir}/.settings.nix.json"
        for f in "$settings" "$last"; do
          if [ -e "$f" ] && ! $jq empty "$f" 2>/dev/null; then
            warnEcho "$f is not valid JSON, moving it to $f.bak"
            run mv -f "$f" "$f.bak"
          fi
        done
        tmp="$(mktemp)"
        $jq -n \
          --slurpfile live <(cat "$settings" 2>/dev/null || echo '{}') \
          --slurpfile last <(cat "$last" 2>/dev/null || echo '{}') \
          --slurpfile new ${settingsFile} '
            def leaves: [paths(type != "object")];
            (($last[0] | leaves) - ($new[0] | leaves)) as $stale
            | reduce $stale[] as $p ($live[0]; . as $o | try delpaths([$p]) catch $o)
            | . * $new[0]
          ' > "$tmp"
        run install -Dm600 "$tmp" "$settings"
        run install -Dm600 ${settingsFile} "$last"
        rm -f "$tmp"
      '';

      # Register global MCP servers idempotently on every home activation.
      home.activation.claudeMcpServers = lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [ -x "${claudeBin}" ]; then
          ${lib.concatStrings (lib.mapAttrsToList registerMcp mcpServers)}
        fi
      '';
    };
  };
}
