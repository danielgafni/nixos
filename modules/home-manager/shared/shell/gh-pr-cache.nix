# Shared shell snippet for computing the GitHub PR cache file path.
# Sets: $cache_dir, $repo_id, $branch, $branch_id, $cache_file
''
  cache_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/starship"
  repo_id=$(git rev-parse --show-toplevel 2>/dev/null | md5sum | cut -c1-8)
  branch=$(git branch --show-current 2>/dev/null)
  branch_id=$(echo "$branch" | md5sum | cut -c1-8)
  cache_file="$cache_dir/gh_pr_''${repo_id}_''${branch_id}"
''
