{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.deduplication;
  dedupScript = pkgs.writeShellScript "run-jdupes" ''
    exec ${pkgs.jdupes}/bin/jdupes -y . -X nostr:.cache/ -Lr ${concatMapStringsSep " " toString cfg.paths}
  '';
in
{
  options.deduplication = {
    enable = mkEnableOption "Enable deduplication with jdupes";

    paths = mkOption {
      type = types.listOf types.path;
      default = [ ];
      description = "List of paths to deduplicate (e.g., [ /nix /var /home/user ])";
    };

    period = mkOption {
      type = types.str;
      default = "weekly";
      example = "daily";
      description = "Systemd OnCalendar-compatible string (e.g., daily, weekly, or cron-style)";
    };
  };

  config = {
    systemd.services.jdupes-deduplication = {
      description = "Run jdupes deduplication on specified paths";
      wantedBy = if cfg.enable then [ "multi-user.target" ] else [ ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${dedupScript}";
        StateDirectory = "jdupes";
        WorkingDirectory = "/var/lib/jdupes";
      };
    };

    systemd.timers.jdupes-deduplication = {
      description = "Scheduled deduplication with jdupes";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.period;
        Persistent = true;
      };
    };
  };
}
