{ pkgs, user, ... }:

{
  programs.adb.enable = true;

  users.users.${user.name}.extraGroups = [ "adbusers" "docker" ];

  environment.systemPackages = with pkgs; [
    awscli
    awslogs
    blender
    brakeman
    cachix
    cargo
    claude-code
    cmake
    codex
    d-spy
    direnv
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
    inkscape
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

  home-manager.users.${user.name} = {
    programs.vscode = {
      enable = true;
      profiles.default.extensions = with pkgs.vscode-extensions; [
        # C/C++ development
        ms-vscode.cmake-tools
        ms-vscode.cpptools
        twxs.cmake

        # Git & GitHub
        eamodio.gitlens
        github.copilot
        github.copilot-chat
        github.vscode-github-actions

        # Markdown
        bierner.github-markdown-preview
        bierner.markdown-checkbox
        bierner.markdown-emoji
        bierner.markdown-footnotes
        bierner.markdown-mermaid
        bierner.markdown-preview-github-styles

        # Nix ecosystem
        arrterian.nix-env-selector
        bbenoist.nix
        jnoortheen.nix-ide
        mkhl.direnv

        # Other tools
        ms-dotnettools.csharp
        ms-dotnettools.vscode-dotnet-runtime
        vscodevim.vim
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        # Extensions from VSCode marketplace
        # Note: anthropic.claude-code and github.copilot-labs removed (not available/deprecated)
        {
          name = "nixfmt-vscode";
          publisher = "brettm12345";
          version = "0.0.1";
          sha256 = "07w35c69vk1l6vipnq3qfack36qcszqxn8j3v332bl0w6m02aa7k";
        }
        {
          name = "nix-extension-pack";
          publisher = "pinage404";
          version = "1.0.0";
          sha256 = "10hi9ydx50zd9jhscfjiwlz3k0v4dfi0j8p58x8421rk5dspi98x";
        }
        {
          name = "godot-tools";
          publisher = "geequlim";
          version = "2.5.1";
          sha256 = "1rlmn3mmy1k79zfirxmjfhjkcwayffrvyjdr1623dmvhsr4d234h";
        }
        {
          name = "gdscript-toolkit-formatter";
          publisher = "razoric";
          version = "1.2.3";
          sha256 = "00ll4pb6ws5kdm1024f8ghrp3ipzg49pq9bwnn4fb0hnyj82zjc0";
        }
        {
          name = "debug";
          publisher = "webfreak";
          version = "0.27.0";
          sha256 = "0z72kls30miqg2rmdlz7knvjx6ywnip9vnxk562p4xg5qm8kkyd7";
        }
        {
          name = "pre-commit-helper";
          publisher = "elagil";
          version = "0.1.0";
          sha256 = "1b9kcrngip7jajfmg4jp9dwxf22agqhm7mhvyagskgnxxd8d5kw0";
        }
      ];
    };
  };
}
