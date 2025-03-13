# this is a common LSP config that can be reused across multiple editors
{
  nil = {
    nix = {
      flake = {
        autoArchive = true;
      };
    };
  };
  basedpyright = {
    binary = {
      path = ".venv/bin/basedpyright-langserver";
      arguments = [
        "--stdio"
      ];
    };
    settings = {
      python = {
        pythonPath = ".venv/bin/python";
      };
    };
  };
  pyright = {
    binary = {
      path = ".venv/bin/pyright-langserver";
      arguments = [
        "--stdio"
      ];
    };
    settings = {
      python = {
        pythonPath = ".venv/bin/python";
      };
    };
  };
  yaml-language-server = {
    settings = {
      editor = {
        tabSize = 2;
      };
    };
  };
  rust-analyzer = {
    initialization_options = {
      cargo = {
        allFeatures = true;
        buildScripts = {
          rebuildOnSave = true;
        };
      };
      procMacro = {
        enable = true;
      };
      checkOnSave = {
        command = "clippy";
      };
      hover = {
        references = {
          enabled = true;
        };
      };
    };
  };
  typos = {
    initialization_options = {
      # Path to your typos config file, .typos.toml by default.
      config = ".typos.toml";
      # Diagnostic severity within Zed. "Error" by default, can be:
      # "Error", "Hint", "Information", "Warning"
      diagnosticSeverity = "Error";
      # Minimum logging level for the LSP, displayed in Zed's logs. "info" by default, can be:
      # "debug", "error", "info", "off", "trace", "warn"
      logLevel = "info";
      # Traces the communication between ZED and the language server. Recommended for debugging only. "off" by default, can be:
      # "messages", "off", "verbose"
      trace.server = "off";
    };
  };
}
