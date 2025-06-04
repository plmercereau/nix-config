{
  pkgs,
  lib,
  config,
  ...
}: let
  extensions = config.programs.vscode.profiles.default.extensions;
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
    profiles.default = {
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
          aaron-bond.better-comments
          platformio.platformio-vscode-ide
          thenuprojectcontributors.vscode-nushell-lang
          eamodio.gitlens
          signageos.signageos-vscode-sops
        ]
        ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "grammarly";
            publisher = "znck";
            version = "0.23.15";
            sha256 = "sha256-/LjLL8IQwQ0ghh5YoDWQxcPM33FCjPeg3cFb1Qa/cb0=";
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
      userSettings = {
        "editor.formatOnSave" = true;
        "editor.inlineSuggest.enabled" = true;
        "extensions.autoUpdate" = false; # The configuration is immutable: disable updates
        "extensions.ignoreRecommendations" = true;
        "git.confirmSync" = false;
        "git.replaceTagsWhenPull" = true;
        "python.formatting.provider" = "black";
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

        # ONLY FOR prettier-vscode
        "eslint.format.enable" = true;
        "[javascript]" = {
          "editor.defaultFormatter" = "dbaeumer.vscode-eslint";
        };
        "[typescript]" = {
          "editor.defaultFormatter" = "dbaeumer.vscode-eslint";
        };
        # "[typescriptreact]" = {
        #   "editor.defaultFormatter" = "esbenp.prettier-vscode";
        # };

        "editor.codeActionsOnSave" = {
          "source.organizeImports" = "always";
          "source.fixAll" = "always";
          "source.fixAll.eslint" = "always";
          "source.fixAll.ts" = "always";
          "source.addMissingImports.ts" = "always";
          "source.sortImports" = "always";
        };
        # ONLY FOR esbenp.prettier-vscode
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
        "better-comments.tags" = [
          {
            "tag" = "!";
            "color" = "#FF2D00";
          }
          {
            "tag" = "?";
            "color" = "#3498DB";
          }
          {
            "tag" = "//";
            "color" = "#474747";
            "strikethrough" = true;
          }
          {
            "tag" = "todo";
            "color" = "#FF8C00";
          }
          {
            "tag" = "*";
            "color" = "#98C379";
          }
          {
            "tag" = "fixme";
            "color" = "#FF2D00";
          }
        ];
        "chat.mcp.enabled" = true;
        mcp = {
          inputs = [
            {
              type = "promptString";
              id = "github_token";
              description = "GitHub Personal Access Token";
              password = true;
            }
          ];

          servers = {
            github = {
              command = "docker";
              args = [
                "run"
                "-i"
                "--rm"
                "-e"
                "GITHUB_PERSONAL_ACCESS_TOKEN"
                "ghcr.io/github/github-mcp-server"
              ];
              env = {
                GITHUB_PERSONAL_ACCESS_TOKEN = "\${input:github_token}";
              };
            };
            # filesystem = {
            #   command = "npx";
            #   args = [
            #     "-y"
            #     "@modelcontextprotocol/server-filesystem"
            #     "\${workspaceFolder}"
            #   ];
            # };
          };
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
  };
}
