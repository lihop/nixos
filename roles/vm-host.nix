{ config, inputs, lib, pkgs, user, ... }:
let
  nixVirt = inputs.NixVirt;
  vmDir = "/home/${user.name}/vms";
  subnetByte = 71;
in
{
  imports = [
    nixVirt.nixosModules.default
    ../modules/i915-sriov.nix
  ];

  hardware.i915-sriov = {
    enable = true;
    numVFs = 3;
  };

  virtualisation = {
    libvirt.enable = true;
    libvirt.swtpm.enable = true;
    libvirtd.enable = true;
  };
  programs = {
    dconf.enable = true; # Enable dconf so virt-manager's settings are saved.
    virt-manager.enable = true;
  };
  users.users.${user.name}.extraGroups = [ "kvm" "libvirtd" "qemu-libvirtd" ];

  virtualisation.libvirt.connections."qemu:///system".networks = [
    {
      active = true;
      definition = nixVirt.lib.network.writeXML (nixVirt.lib.network.templates.bridge {
        uuid = "41b3ed81-67b3-44eb-b9b9-4e40538544f3";
        subnet_byte = subnetByte;
      });
    }
  ];

  # File sharing.
  users.users.dev = {
    isNormalUser = true;
    home = "/var/empty";
    shell = "${pkgs.shadow}/bin/nologin";
    hashedPassword = "!";
  };
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "hosts allow" = "192.168.${toString subnetByte}.";
        "hosts deny" = "0.0.0.0/0";
        "server signing" = "auto";
        "allow insecure wide links" = "yes";
      };
      vm_share = {
        "path" = "${vmDir}/shared";
        "valid users" = "dev";
        "read only" = "no";
        "force user" = user.name;
        "follow symlinks" = "yes";
        "wide links" = "yes"; # Allow symlinks pointing outside the share.
      };
    };
  };
  system.activationScripts.sambaPasswd = ''
    echo -ne "dev\ndev\n" | ${pkgs.samba}/bin/smbpasswd -a dev -s
  '';

  virtualisation.libvirt.connections."qemu:///system".pools = [
    {
      active = true;
      definition = nixVirt.lib.pool.writeXML {
        name = "default";
        uuid = "5f1cd56b-7c91-4632-acfc-3a843c44cbf2";
        type = "dir";
        target = { path = "/var/lib/libvirt/images"; };
      };
      volumes = [
        {
          present = true;
          definition = nixVirt.lib.volume.writeXML {
            name = "win11.img";
            capacity = { count = 80; unit = "GiB"; };
            target.format.type = "raw";
          };
        }
        {
          present = true;
          definition = nixVirt.lib.volume.writeXML {
            name = "win11-full.img";
            capacity = { count = 80; unit = "GiB"; };
            target.format.type = "raw";
          };
        }
      ];
    }
  ];

  home-manager.users.${user.name} = { config, lib, osConfig, pkgs, ... }: {
    home.activation."create-nvram-files" = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
      [ -f ${vmDir}/config/win11.nvram ] || install --mode 0644 -D ${pkgs.OVMFFull.fd}/FV/OVMF_VARS.ms.fd ${vmDir}/config/win11.nvram
      [ -f ${vmDir}/config/win11-full.nvram ] || install --mode 0644 -D ${pkgs.OVMFFull.fd}/FV/OVMF_VARS.ms.fd ${vmDir}/config/win11-full.nvram
    '';
  };
  virtualisation.libvirt.connections."qemu:///system".domains =
    let
      mkWindowsVM = { name, uuid, volume, pciFunction, vcpus ? 2 }:
        let
          baseXML = nixVirt.lib.domain.templates.windows {
            inherit name uuid;
            vcpu = { count = vcpus; };
            memory = { count = 8; unit = "GiB"; };
            install_virtio = true;
            install_vol = "${vmDir}/iso/Win11_24H2_EnglishInternational_x64.iso";
            nvram_path = "${vmDir}/config/${name}.nvram";
            virtio_drive = true;
            virtio_net = true;
            virtio_video = false;
          };
        in
        {
          active = false;
          definition = nixVirt.lib.domain.writeXML (
            baseXML // {
              features = {
                acpi = { };
                apic = { };
                hyperv = {
                  mode = "custom";
                  relaxed.state = true;
                  vapic.state = true;
                  spinlocks = { state = true; retries = 8191; };
                  vendor_id = { state = true; value = "GenuineIntel"; };
                };
                vmport.state = false;
                kvm.hidden.state = true;
                ioapic = { driver = "kvm"; };
              };
              memoryBacking = { source.type = "memfd"; access.mode = "shared"; };
              devices = baseXML.devices // {
                disk = baseXML.devices.disk ++ [
                  {
                    type = "volume";
                    device = "disk";
                    driver = { name = "qemu"; type = "raw"; };
                    source = { pool = "default"; inherit volume; };
                    target = { dev = "vda"; bus = "virtio"; };
                    address = { type = "pci"; bus = 4; };
                  }
                ];
                filesystem = [
                  {
                    type = "mount";
                    accessmode = "passthrough";
                    binary = { path = "${pkgs.virtiofsd}/bin/virtiofsd"; };
                    driver = { type = "virtiofs"; };
                    source = { dir = "${vmDir}/shared"; };
                    target = { dir = "mount_shared"; };
                  }
                ];
                hostdev = [
                  {
                    type = "pci";
                    managed = true;
                    source.address = { slot = 2; function = pciFunction; };
                    address = { type = "pci"; bus = 8; };
                  }
                ];
              };
            }
          );
        };
    in
    [
      (mkWindowsVM {
        name = "win11";
        uuid = "c29f2546-2377-4e6b-9937-0c18520142fc";
        volume = "win11.img";
        pciFunction = 1;
        vcpus = 2;
      })
      (mkWindowsVM {
        name = "win11-full";
        uuid = "a29f2546-2377-4e6b-9937-0c18520142fd";
        volume = "win11-full.img";
        pciFunction = 2;
        vcpus = 10;
      })
    ];
}
