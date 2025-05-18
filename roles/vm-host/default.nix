{ config, inputs, pkgs, username, ... }:
let
  nixVirt = inputs.NixVirt;
  vmDir = "/home/leroy/vms";
in
{
  imports = [ nixVirt.nixosModules.default ];

  boot.kernelParams = [ "intel_iommu=on" "iommu=pt" ];
  boot.extraModprobeConfig = ''
    options vfio-pci ids=10de:1201,10de:0e0c,8086:a780
    blacklist nouveau
    blacklist snd_hda_intel
    blacklist snd_soc_avs
    blacklist snd_sof_pci_intel_tgl
    blacklist i915
  '';

  users.users.leroy.extraGroups = [ "kvm" "libvirtd" "qemu-libvirtd" ];

  virtualisation.libvirt.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirt.swtpm.enable = true;
  virtualisation.libvirt.connections."qemu:///system".networks = [
    {
      active = true;
      definition = nixVirt.lib.network.writeXML (nixVirt.lib.network.templates.bridge {
        uuid = "41b3ed81-67b3-44eb-b9b9-4e40538544f3";
        subnet_byte = 71;
      });
    }
  ];

  home-manager.users.leroy = { config, lib, osConfig, pkgs, ... }: {
    home.activation."create-nvram-files" = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
      [ -f ${vmDir}/windows/win11.nvram ] || install --mode 0644 -D ${pkgs.OVMFFull.fd}/FV/OVMF_VARS.ms.fd ${vmDir}/windows/win11.nvram
    '';
  };

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
          present = false;
          definition = nixVirt.lib.volume.writeXML {
            name = "win10.raw";
            capacity = { count = 64; unit = "GiB"; };
            target.format.type = "raw";
          };
        }
        {
          present = true;
          definition = nixVirt.lib.volume.writeXML {
            name = "win11.raw";
            capacity = { count = 64; unit = "GiB"; };
            target.format.type = "raw";
          };
        }
      ];
    }
  ];
  virtualisation.libvirt.connections."qemu:///system".domains = [
    {
      active = false;
      definition =
        let
          baseDir = "${vmDir}/windows";
          baseXML = nixVirt.lib.domain.templates.windows {
            name = "win11";
            uuid = "c29f2546-2377-4e6b-9937-0c18520142fc";
            memory = { count = 8; unit = "GiB"; };
            install_virtio = true;
            install_vol = "${vmDir}/storage/Win11_24H2_EnglishInternational_x64.iso";
            nvram_path = "${vmDir}/windows/win11.nvram";
            virtio_drive = true;
            virtio_net = true;
            virtio_video = false;
          };
        in
        nixVirt.lib.domain.writeXML (
          baseXML // {
            features = {
              acpi = { };
              apic = { };
              hyperv.vendor_id = { state = true; value = "ugh"; };
              vmport.state = false;
              kvm.hidden.state = true;
              ioapic = { driver = "kvm"; };
            };
            devices = baseXML.devices // {
              disk = baseXML.devices.disk ++ [
                {
                  type = "volume";
                  device = "disk";
                  driver = { name = "qemu"; type = "raw"; };
                  source = { pool = "default"; volume = "win11.raw"; };
                  target = { dev = "vda"; bus = "virtio"; };
                  address = { type = "pci"; bus = 4; };
                }
              ];
              hostdev = [
                {
                  type = "pci";
                  managed = true;
                  source.address.bus = 4;
                  address = { type = "pci"; bus = 6; };
                }
                {
                  type = "pci";
                  managed = true;
                  source.address = { bus = 4; function = 1; };
                  address = { type = "pci"; bus = 7; };
                }
              ];
            };
          }
        );
    }
  ];

  environment.systemPackages = with pkgs; [
    (virt-manager.override { spice-gtk = spice-gtk; })
    virt-viewer
  ];

  programs = {
    # Enable dconf so that virt-managers settings are saved.
    dconf.enable = true;
    virt-manager.enable = true;
  };
}
