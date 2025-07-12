# Based on Vadika's NixOS config: https://github.com/vadika/nixos-config.
{ config, kernelPackages, lib, pkgs, ... }:

with lib;

let
  cfg = config.hardware.i915-sriov;

  customKernel = cfg.kernel.override {
    structuredExtraConfig = with lib.kernel; {
      DRM_I915_PXP = yes;
      INTEL_MEI_PXP = module;
    };
  };
  customKernelPackages = pkgs.linuxPackagesFor customKernel;

  i915SRIOVModule = customKernelPackages.callPackage
    ({ stdenv, kernel }:
      stdenv.mkDerivation rec {
        pname = "i915-sriov-dkms";
        version = "2025.05.18";

        src = pkgs.fetchFromGitHub {
          owner = "strongtz";
          repo = "i915-sriov-dkms";
          rev = version;
          sha256 = "sha256-AMwYBAQvY6QYvRQ9aEPqUWhCr38DYgZySopFbDnuqUw=";
        };

        nativeBuildInputs = kernel.moduleBuildDependencies ++ [ pkgs.xz ];

        makeFlags = [
          "KERNELRELEASE=${kernel.modDirVersion}"
          "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
        ];

        buildPhase = ''
          make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
            M=$(pwd) \
            KERNELRELEASE=${kernel.modDirVersion}
        '';

        installPhase = ''
          mkdir -p $out/lib/modules/${kernel.modDirVersion}/extra
          ${pkgs.xz}/bin/xz -z -f i915.ko
          cp i915.ko.xz $out/lib/modules/${kernel.modDirVersion}/extra/i915-sriov.ko.xz
        '';

        meta = with lib; {
          description = "Custom module for i915 SRIOV support";
          homepage = "https://github.com/strongtz/i915-sriov-dkms";
          license = licenses.gpl2Only;
          platforms = platforms.linux;
        };
      })
    { };
in
{
  options.hardware.i915-sriov = {
    enable = mkEnableOption "i915 SR-IOV support";

    numVFs = mkOption {
      type = types.int;
      default = 3;
      description = "Number of virtual functions to create.";
    };

    kernel = mkOption {
      type = types.package;
      default = kernelPackages.kernel;
      description = "The kernel package to use.";
    };
  };

  config = mkIf cfg.enable {
    boot.kernelPackages = lib.mkForce customKernelPackages;
    boot.extraModulePackages = [ i915SRIOVModule ];

    boot.blacklistedKernelModules = [ "i915" "xe" ];

    boot.kernelModules = [ "i915-sriov" "mei_pxp" ];
    boot.initrd.kernelModules = [ "i915-sriov" ];

    boot.kernelParams = [
      "intel_iommu=on"
      "i915.enable_guc=3"
    ];

    boot.extraModprobeConfig = ''
      alias i915 i915-sriov
      options i915-sriov enable_guc=3 max_vfs=${toString cfg.numVFs}
      softdep i915-sriov post: mei_pxp
    '';

    boot.postBootCommands = ''
      /run/current-system/sw/bin/depmod -a ${customKernel.modDirVersion}
    '';

    systemd.tmpfiles.rules = [
      "w /sys/devices/pci0000:00/0000:00:02.0/sriov_numvfs - - - - ${toString cfg.numVFs}"
    ];
  };
}
