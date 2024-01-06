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
    godot_4
    python3Packages.grip
    jdk11
    jekyll
    just
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
    pkg-config
    pre-commit
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
      package = pkgs.vscode.fhs;
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
