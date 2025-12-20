{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.duperemove;

  excludeArgs = concatMapStringsSep " " (x: "--exclude=${x}") cfg.excludes;

  duperemoveScript = pkgs.writeShellScript "run-duperemove" ''
    ${pkgs.util-linux}/bin/ionice -c 3 ${pkgs.coreutils}/bin/nice -n 19 \
      ${pkgs.duperemove}/bin/duperemove \
      -dr \
      --hashfile=${cfg.hashfile} \
      ${excludeArgs} \
      ${concatStringsSep " " cfg.paths}
  '';
in
{
  options.duperemove = {
    enable = mkEnableOption "Enable block-level deduplication with duperemove";

    paths = mkOption {
      type = types.listOf types.str;
      default = [ "/" ];
      description = "List of paths to deduplicate (e.g., [ \"/\" \"/home\" ])";
    };

    excludes = mkOption {
      type = types.listOf types.str;
      default = [ ".snapshots" ];
      description = "Patterns to exclude from deduplication (e.g., [ \".snapshots\" \".cache\" ])";
    };

    hashfile = mkOption {
      type = types.path;
      default = "/var/lib/duperemove/hashfile.db";
      description = "Path to store duperemove hash database";
    };

    period = mkOption {
      type = types.str;
      default = "weekly";
      example = "daily";
      description = "Systemd OnCalendar-compatible string (e.g., daily, weekly, or cron-style)";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.duperemove-deduplication = {
      description = "Run duperemove block-level deduplication";
      after = [ "local-fs.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${duperemoveScript}";
        StateDirectory = "duperemove";
        WorkingDirectory = "/var/lib/duperemove";
        RemainAfterExit = false;
        IOSchedulingClass = "idle";
        CPUSchedulingPolicy = "idle";

        # Resource limits to prevent interference with gaming/work
        MemoryMax = "4G"; # Limit memory to 4GB (was using 13.5GB!)
        MemoryHigh = "3G"; # Start throttling at 3GB
        CPUQuota = "25%"; # Limit to 25% of one CPU core
        TasksMax = "50"; # Limit number of threads

        # Additional I/O limits
        IOReadBandwidthMax = "/ 50M"; # Max 50MB/s read
        IOWriteBandwidthMax = "/ 10M"; # Max 10MB/s write

        # Nice features for manual control
        KillMode = "mixed"; # Clean shutdown
        TimeoutStopSec = "30s"; # Give it time to save state
      };
    };

    systemd.timers.duperemove-deduplication = {
      description = "Scheduled block-level deduplication with duperemove";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.period;
        Persistent = true;
      };
    };
  };
}
