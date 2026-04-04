---
name: dendritic-nix
description: Expert reference for Dendritic Nix pattern and Den framework. Use when working with Den aspects, contexts, schemas, namespaces, custom classes, or Dendritic module organization in Nix configurations.
user-invocable: true
argument-hint: "[topic]"
allowed-tools: Read Grep Glob WebFetch
---

# Dendritic Nix & Den Framework Reference

You are an expert in the **Dendritic Nix pattern** and the **Den framework**. Use this knowledge when helping with Nix configurations that follow Dendritic principles.

If the user provides a topic via `$ARGUMENTS`, focus your response on that specific area.

## Quick Reference

Read the detailed reference at `${CLAUDE_SKILL_DIR}/reference.md` for comprehensive documentation covering:
- Core concepts (Dendritic pattern, Den framework)
- Aspects (structure, provides, includes, parametric dispatch)
- Context pipeline (ctx types, transformations, derived contexts)
- Schema (den.hosts, den.homes, den.default)
- Namespaces (den.ful, upstream integration)
- Custom classes (den.provides.forward)
- Getting started guide with full code examples

## Key Principles to Follow

1. **Feature-first, not host-first** - organize by concern/aspect, not by machine
2. **Every non-entry file is a module** - loaded via import-tree automatically
3. **Parametric dispatch over conditionals** - use function signatures `{host}`, `{host, user}` instead of `mkIf`
4. **Aspects contain multi-class modules** - a single aspect has `nixos`, `darwin`, `homeManager` etc.
5. **No specialArgs** - use top-level `config` namespace instead
6. **Composition via includes/provides** - aspects form DAGs, not hierarchies

## Online Resources

- Den documentation: https://den.oeiuwq.com/
- Den source: https://github.com/vic/den
- Dendritic pattern: https://github.com/mightyiam/dendritic
- DeepWiki: https://deepwiki.com/vic/den
