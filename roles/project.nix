{ config, pkgs, ... }:

{
  programs.adb.enable = true;
  users.users.leroy.extraGroups = [ "adbusers" ];

  environment.systemPackages = with pkgs; [
    awscli
    cargo
    clang_9
    dfeet
    docker-compose
    dotnetCorePackages.sdk_6_0
    dotnetPackages.Nuget
    edb
    fastlane
    gd
    gitlab-runner
    gitAndTools.git-filter-repo
    python3Packages.grip
    jdk11
    jekyll
    k6
    kops
    kubectl
    kubectx
    kubernetes-helm
    kustomize
    libguestfs
    libimobiledevice
    mariadb-client
    minio-client
    ncurses.dev
    nodejs-18_x
    nodePackages.node2nix
    nodePackages.react-native-cli
    pkg-config
    react-native-debugger
    reuse
    robo3t
    ruby
    rust-analyzer
    rustc
    slack
    sqlite
    terraform.full
    vagrant
    valgrind
    virt-viewer
    yarn
    clang
    clang-tools
    dbus
    ganttproject-bin
    plantuml
    cypress
    scons
    travis
    xvfb-run
  ];

  home-manager.users.leroy = { pkgs, ... }: {
    home.sessionVariables = {
      SCONS_CACHE = "$HOME/.cache/scons-cache";
      EM_CACHE = "$HOME/.cache/em-cache";
    };

    programs.vscode = {
      enable = true;
      package = (pkgs.vscode.override { isInsiders = true; }).overrideAttrs (oldAttrs: rec {
        src = (builtins.fetchTarball {
          url = "https://code.visualstudio.com/sha/download?build=insider&os=linux-x64";
          sha256 = "sha256:1nvmnf4w2894v21zcmh1xzcxzzilc10qsqhz2i5hqvrn2vcw0ivv";
        });
        version = "latest";
      });
      extensions = with pkgs.vscode-extensions; [
        angular.ng-template
        arrterian.nix-env-selector
        bbenoist.nix
        matklad.rust-analyzer
        ms-dotnettools.csharp
        ms-vsliveshare.vsliveshare
        ms-python.python
        ms-vscode.cpptools
        vscodevim.vim
        xaver.clang-format
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "copilot-nightly";
          publisher = "GitHub";
          version = "1.45.6799";
          sha256 = "sha256-OCTQEINMWRVs2j62d4ahLN/r/5w2h2ICacI0dvhuNPw=";
        }
        {
          name = "godot-tools";
          publisher = "geequlim";
          version = "1.3.1";
          sha256 = "sha256-wJICDW8bEBjilhjhoaSddN63vVn6l6aepPtx8VKTdZA=";
        }
      ];
    };
  };

  # Needed to store VSCode auth token.
  services.gnome.gnome-keyring.enable = true;

  # Set environment variables required by PlantUML LaTeX plugin.
  environment.variables.PLANTUML_JAR = "${pkgs.plantuml}/lib/plantuml.jar";
  environment.variables.GRAPHVIZ_DOT = "${pkgs.graphviz}/bin/dot";
  environment.variables.LIBCLANG_PATH = "${pkgs.llvmPackages.libclang}/lib";

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
}
