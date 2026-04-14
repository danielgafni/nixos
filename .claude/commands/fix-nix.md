Check nil LSP diagnostics and statix lints for all `.nix`:

- `statix check`
- `nix fmt .`

Fix any errors or warnings reported. If nil is not available as a CLI, use `nix flake check 2>&1 | head -50` as a fallback to find Nix evaluation errors. If statix is not available, skip its checks.
