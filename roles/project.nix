{ config, pkgs, ... }:
let
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    toolsVersion = "26.1.1";
    platformToolsVersion = "33.0.2";
    buildToolsVersions = [ "28.0.3" ];
    platformVersions = [ "28" "29" ];
    useGoogleAPIs = true;
    includeExtras = [
      "extras;google;gcm"
    ];
  };
in
{
  programs.adb.enable = true;
  users.users.leroy.extraGroups = [ "adbusers" ];

  nixpkgs.config.android_sdk = {
    accept_license = true;
  };
  environment.variables.ANDROID_SDK_ROOT = "${androidComposition.androidsdk}/libexec/android-sdk";

  environment.systemPackages = with pkgs; [
    androidComposition.androidsdk
    android-studio
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
    libimobiledevice
    mariadb-client
    minio-client
    mongodb
    mongodb-tools
    nodejs-16_x
    nodePackages.node2nix
    nodePackages.react-native-cli
    pkgconfig
    react-native-debugger
    reuse
    robo3t
    ruby
    rust-analyzer
    slack
    valgrind
    virt-viewer
    (yarn.overrideAttrs (oldAttrs: {
      # Use different version of nodejs with yarn.
      buildInputs = [ nodejs-16_x ];
    }))
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
    programs.vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        arrterian.nix-env-selector
        bbenoist.nix
        github.copilot
        matklad.rust-analyzer
        ms-dotnettools.csharp
        ms-python.python
        ms-vscode.cpptools
        xaver.clang-format
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
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
