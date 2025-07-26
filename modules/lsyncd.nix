{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.lsyncd;

  # Generate sync blocks for lsyncd config.
  syncBlocks = map
    (syncItem: ''
      sync {
        default.rsync,
        source = "${syncItem.source}/",
        target = "${syncItem.target}/",
        rsync = {
          acls = true,
          archive = true,
          binary = "${pkgs.rsync}/bin/rsync",
          hard_links = true,
          xattrs = true,
        }
      }
    '')
    cfg.sync;

  # Extract sources and targets for systemd permissions.
  sources = map (syncItem: syncItem.source) cfg.sync;
  targets = map (syncItem: syncItem.target) cfg.sync;

  configFile = pkgs.writeText "lsyncd.conf" ''
    settings {
      nodaemon = true,
    }
    ${concatStringsSep "\n" syncBlocks}
  '';

in
{
  options.services.lsyncd = {
    enable = mkEnableOption "lsyncd continuous file synchronization";

    sync = mkOption {
      type = types.listOf (types.submodule {
        options = {
          source = mkOption {
            type = types.str;
            description = "Source directory to synchronize";
            example = "/home/user/documents";
          };
          target = mkOption {
            type = types.str;
            description = "Target directory for backup";
            example = "/var/backup/documents";
          };
        };
      });
      default = [ ];
      description = "List of source/target pairs to synchronize";
      example = [
        { source = "/home/user/.ssh"; target = "/var/backup/.ssh"; }
        { source = "/home/user/documents"; target = "/var/backup/documents"; }
      ];
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.sync != [ ];
        message = "services.lsyncd.sync cannot be empty";
      }
    ];

    environment.systemPackages = with pkgs; [ lsyncd rsync ];

    # Ensure target parent directories exist.
    systemd.tmpfiles.rules = map (syncItem: "d ${dirOf syncItem.target} 0755 root root -") cfg.sync;

    systemd.services.lsyncd = {
      description = "Live Syncing (Mirror) Daemon";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.lsyncd}/bin/lsyncd ${configFile}";
        ReadOnlyPaths = sources;
        ReadWritePaths = map (syncItem: dirOf syncItem.target) cfg.sync;
      };

      preStart = ''
        # Ensure all source paths exist
        ${concatMapStringsSep "\n" (source: ''
          if [ ! -e "${source}" ]; then
            echo "Warning: Source path ${source} does not exist"
          fi
        '') sources}
      '';
    };
  };
}
