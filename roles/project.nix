{ pkgs, ... }:

{
  programs.adb.enable = true;

  users.users.leroy.extraGroups = [ "adbusers" "docker" ];

  environment.systemPackages = with pkgs; [
    awscli
    awslogs
    blender
    brakeman
    cachix
    cargo
    cmake
    d-spy
    dmg2img
    docker-compose
    doxygen
    edb
    fastlane
    figma-linux
    gd
    gitlab-runner
    gitAndTools.git-filter-repo
    godot_4
    python3Packages.grip
    python3Packages.myst-parser
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
    minio
    minio-client
    ncurses.dev
    nodejs_20
    nodePackages.node2nix
    peek
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
    valgrind
    yarn
    clang
    clang-tools
    dbus
    ganttproject-bin
    plantuml
    qemu
    cypress
    scons
    travis
    xvfb-run
  ];

  # Needed to store VSCode auth token.
  services.gnome.gnome-keyring.enable = true;

  # Set environment variables required by PlantUML LaTeX plugin.
  environment.variables.PLANTUML_JAR = "${pkgs.plantuml}/lib/plantuml.jar";
  environment.variables.GRAPHVIZ_DOT = "${pkgs.graphviz}/bin/dot";
  environment.variables.LIBCLANG_PATH = "${pkgs.llvmPackages.libclang}/lib";

  hardware.bluetooth.enable = true;

  boot.kernelModules = [ "kvm-intel" ];

  virtualisation.docker.enable = true;
}
