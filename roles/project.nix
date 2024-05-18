{ config, pkgs, ... }:

{
  programs.adb.enable = true;
  users.users.leroy.extraGroups = [ "adbusers" ];

  environment.systemPackages = with pkgs; [
    awscli
    cargo
    clang_9
    cmake
    dfeet
    docker-compose
    dotnetCorePackages.sdk_6_0
    dotnetPackages.Nuget
    doxygen
    edb
    fastlane
    gd
    gitlab-runner
    gitAndTools.git-filter-repo
    godot3
    (godot_4.overrideAttrs (oldAttrs: {
      sconsFlags = oldAttrs.sconsFlags ++ [ "debug_symbols=yes" ];
    }))
    python3Packages.grip
    python3Packages.pip
    python3Packages.sphinx
    python3Packages.sphinx_rtd_theme
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
    nodejs_20
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
