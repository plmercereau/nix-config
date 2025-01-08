{
  pkgs,
  lib,
  config,
  ...
}: let
  extensions = config.programs.vscode.extensions;
in {
  home.packages = with pkgs; (
    (lib.optional (builtins.elem vscode-extensions.bbenoist.nix extensions) alejandra)
    ++ (lib.optional (builtins.elem vscode-extensions.ms-python.python extensions) black)
  );

  programs.git.extraConfig = {
    core.editor = "code --wait";
    diff.tool = "vscode";
    difftool.vscode.cmd = "code --wait --diff $LOCAL $REMOTE";
    merge.tool = "vscode";
    mergetool.vscode.cmd = "code --wait $MERGED";
  };

  home.sessionVariables = {
    EDITOR = lib.mkForce "code --wait";
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    extensions = with pkgs.vscode-extensions;
      [
        bbenoist.nix
        dbaeumer.vscode-eslint
        esbenp.prettier-vscode
        vue.volar
        github.copilot
        github.copilot-chat
        graphql.vscode-graphql
        graphql.vscode-graphql-syntax
        jdinhlife.gruvbox
        kamadorueda.alejandra
        ms-azuretools.vscode-docker
        ms-vscode-remote.remote-ssh
        redhat.vscode-yaml
        tamasfe.even-better-toml
        unifiedjs.vscode-mdx
        vscode-icons-team.vscode-icons
        yzhang.markdown-all-in-one
        ms-python.python
        mkhl.direnv
        ms-kubernetes-tools.vscode-kubernetes-tools
        hashicorp.terraform
        golang.go
      ]
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "platformio-ide";
          publisher = "platformio";
          version = "3.3.3";
          sha256 = "sha256-pcWKBqtpU7DVpiT7UF6Zi+YUKknyjtXFEf5nL9+xuSo=";
        }
        {
          name = "better-comments";
          publisher = "aaron-bond";
          version = "3.0.2";
          sha256 = "sha256-hQmA8PWjf2Nd60v5EAuqqD8LIEu7slrNs8luc3ePgZc=";
        }
        {
          name = "grammarly";
          publisher = "znck";
          version = "0.23.15";
          sha256 = "sha256-/LjLL8IQwQ0ghh5YoDWQxcPM33FCjPeg3cFb1Qa/cb0=";
        }
        {
          name = "vscode-nushell-lang";
          publisher = "TheNuProjectContributors";
          version = "1.9.0";
          sha256 = "sha256-E9CK/GChd/yZT+P3ttROjL2jHtKPJ0KZzc32/nbuE4w=";
        }
        {
          name = "toit";
          publisher = "toit";
          version = "1.8.8";
          sha256 = "sha256-cgnoHn/S36uBpZN5RJwm/KCpmF90NqWT4Li6qz6x3qQ=";
        }
        # {
        #   name = "kubernetes-yaml-formatter";
        #   publisher = "kennylong";
        #   version = "1.1.0";
        #   sha256 = "sha256-bAdMQxefeqedBdLiYqFBbuSN0auKAs4SKnrqK9/m65c=";
        # }
        # {
        #   name = "esp-idf-extension";
        #   publisher = "espressif";
        #   version = "1.7.1";
        #   sha256 = "sha256-6WemXuS8JIjDYBXfNcrH9ErQj7LigqqxjEXcs0IhYbA=";
        # }
        # # TODO somehow conflicts with platformio. Try the version installed by pio (1.20.5)
        # {
        #   name = "cpptools";
        #   publisher = "ms-vscode";
        #   version = "1.21.0";
        #   sha256 = "sha256-hhH5GCvHiXlKPur9YkJSpz4IAPpCbu46Mu0t1SBGr4Q=";
        # }
        # {
        #   name = "vscode-arduino";
        #   publisher = "vsciot-vscode";
        #   version = "0.6.0";
        #   sha256 = "sha256-fPzY1SI5OAMUlP0FdqPHC5xQIzf7QyG7Uc3RHLmccEY=";
        # }
        # {
        #   name = "vscode-serial-monitor";
        #   publisher = "ms-vscode";
        #   version = "0.12.0";
        #   sha256 = "sha256-G4F5uUILP43QpUteHDMw8WOeftBuNHC+yF/HHtGTKh0=";
        # }
        {
          name = "tilt";
          publisher = "Tchoupinax";
          version = "1.0.9";
          sha256 = "sha256-PbZiCz+D699gURdSisAITBvDQml8eQJOE3uxUBKA3Dk=";
        }
      ];
    userSettings =
      {
        "editor.formatOnSave" = true;
        "editor.inlineSuggest.enabled" = true;
        "extensions.autoUpdate" = false; # The configuration is immutable: disable updates
        "extensions.ignoreRecommendations" = true;
        "git.confirmSync" = false;
        "python.formatting.provider" = "black";
        # "terminal.external.linuxExec" = "alacritty";
        # "terminal.external.osxExec" = "Alacritty.app";
        "terminal.external.linuxExec" = "ghostty";
        "terminal.external.osxExec" = "Ghostty.app";
        "terminal.integrated.fontFamily" = "MesloLGS NF";
        "update.mode" = "none";
        "window.zoomLevel" = 1.2;
        "workbench.colorTheme" = "Gruvbox Dark Medium";
        "files.associations" = {
          "*.yaml.tpl" = "yaml";
        };
        "editor.minimap.enabled" = false;
        "terminal.integrated.enableMultiLinePasteWarning" = "always";
        "security.workspace.trust.untrustedFiles" = "open";
        "C_Cpp.intelliSenseEngine" = "Tag Parser";
        "C_Cpp.clang_format_style" = "Google";
        "grammarly.files.exclude" = [
          "CMakeLists.txr"
        ];
        # "arduino.useArduinoCli" = false;
        # "arduino.path" = "/opt/homebrew/bin/";
        # "arduino.commandPath" = "arduino-cli";
        "[go]" = {
          "editor.defaultFormatter" = "golang.go";
        };
      }
      // lib.optionalAttrs (builtins.elem pkgs.vscode-extensions.esbenp.prettier-vscode extensions) {
        "eslint.format.enable" = true;
        "[javascript]" = {
          "editor.defaultFormatter" = "dbaeumer.vscode-eslint";
        };
        "[typescript]" = {
          "editor.defaultFormatter" = "dbaeumer.vscode-eslint";
        };
        "editor.codeActionsOnSave" = {
          "source.organizeImports" = "always";
          "source.fixAll" = "always";
          "source.fixAll.eslint" = "always";
          "source.fixAll.ts" = "always";
          "source.addMissingImports.ts" = "always";
          "source.sortImports" = "always";
        };
      }
      // lib.optionalAttrs (builtins.elem pkgs.vscode-extensions.esbenp.prettier-vscode extensions) {
        # "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "[json]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[jsonc]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        # "[yaml]" = {
        #   # * See: https://github.com/vscode-kubernetes-tools/vscode-kubernetes-tools/issues/573
        #   "editor.defaultFormatter" = "esbenp.prettier-vscode";
        #   "editor.formatOnSave" = false;
        # };
        "[html]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[markdown]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
      };
    keybindings = [
      {
        key = "cmd+alt+j";
        command = "workbench.action.terminal.toggleTerminal";
        when = "terminal.active";
      }
      {
        key = "cmd+1";
        command = "workbench.action.openEditorAtIndex1";
      }
      {
        key = "cmd+2";
        command = "workbench.action.openEditorAtIndex2";
      }
      {
        key = "cmd+3";
        command = "workbench.action.openEditorAtIndex3";
      }
      {
        key = "cmd+4";
        command = "workbench.action.openEditorAtIndex4";
      }
      {
        key = "cmd+5";
        command = "workbench.action.openEditorAtIndex5";
      }
      {
        key = "cmd+6";
        command = "workbench.action.openEditorAtIndex6";
      }
      {
        key = "cmd+7";
        command = "workbench.action.openEditorAtIndex7";
      }
      {
        key = "cmd+8";
        command = "workbench.action.openEditorAtIndex8";
      }
      {
        key = "cmd+9";
        command = "workbench.action.openEditorAtIndex9";
      }
    ];
  };
}
