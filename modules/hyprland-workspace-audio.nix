{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.hyprland-workspace-audio;

  # Daemon script that monitors applications and routes audio per-app based on workspace
  daemon = pkgs.writeShellScript "hyprland-workspace-audio-daemon" ''
    set -euo pipefail

    # Audio sink mappings
    TV_SINK="${cfg.tvSink}"
    HEADPHONES_SINK="${cfg.headphonesSink}"
    TV_WORKSPACES="${toString cfg.tvWorkspaces}"

    # Cache for sink IDs
    TV_SINK_ID=""
    HEADPHONES_SINK_ID=""

    log() {
      echo "[hyprland-workspace-audio] $*"
    }

    # Get sink ID from sink name by inspecting each sink
    get_sink_id() {
      local sink_name=$1

      # Get all sink IDs from Sinks section only
      local sink_ids=$(${pkgs.wireplumber}/bin/wpctl status | ${pkgs.gnused}/bin/sed -n '/├─ Sinks:/,/├─ Sources:/p' | ${pkgs.gnugrep}/bin/grep -oP '│\s+\*?\s+\K[0-9]+(?=\.)')

      # Check each sink for matching node.name
      for id in $sink_ids; do
        local node_name=$(${pkgs.wireplumber}/bin/wpctl inspect "$id" 2>/dev/null | ${pkgs.gnugrep}/bin/grep "node.name" | head -1 | ${pkgs.gnused}/bin/sed 's/.*"\(.*\)".*/\1/')
        if [ "$node_name" = "$sink_name" ]; then
          echo "$id"
          return 0
        fi
      done

      # Not found
      return 1
    }

    # Initialize sink IDs
    init_sinks() {
      TV_SINK_ID=$(get_sink_id "$TV_SINK")
      HEADPHONES_SINK_ID=$(get_sink_id "$HEADPHONES_SINK")

      if [ -z "$TV_SINK_ID" ] || [ -z "$HEADPHONES_SINK_ID" ]; then
        log "ERROR: Could not find sink IDs"
        log "  TV sink '$TV_SINK' → ID: $TV_SINK_ID"
        log "  Headphones sink '$HEADPHONES_SINK' → ID: $HEADPHONES_SINK_ID"
        exit 1
      fi

      log "Initialized sinks:"
      log "  TV (workspaces $TV_WORKSPACES) → sink $TV_SINK_ID"
      log "  Headphones (other workspaces) → sink $HEADPHONES_SINK_ID"
    }

    # Get workspace ID for a given PID
    get_workspace_for_pid() {
      local pid=$1
      ${pkgs.hyprland}/bin/hyprctl clients -j | ${pkgs.jq}/bin/jq -r ".[] | select(.pid == $pid) | .workspace.id" | head -1
    }

    # Determine target sink for a workspace
    get_sink_for_workspace() {
      local workspace=$1
      if echo "$TV_WORKSPACES" | grep -wq "$workspace"; then
        echo "$TV_SINK_ID"
      else
        echo "$HEADPHONES_SINK_ID"
      fi
    }

    # Route a specific stream based on its PID
    route_stream() {
      local stream_id=$1
      local stream_pid=$2
      local app_name=$3

      # Get workspace for this PID
      local workspace=$(get_workspace_for_pid "$stream_pid")

      if [ -z "$workspace" ]; then
        # PID not found in Hyprland windows, use default (headphones)
        log "Stream $stream_id (PID $stream_pid, $app_name): No window found, using headphones"
        ${pkgs.pipewire}/bin/pw-metadata -n default "$stream_id" target.node "$HEADPHONES_SINK" 2>/dev/null || true
        return
      fi

      # Determine target sink ID and name
      local target_sink_id=$(get_sink_for_workspace "$workspace")
      local target_sink_name=""

      if [ "$target_sink_id" = "$TV_SINK_ID" ]; then
        target_sink_name="$TV_SINK"
        log "Stream $stream_id (PID $stream_pid, $app_name): Workspace $workspace → TV (sink $target_sink_id)"
      else
        target_sink_name="$HEADPHONES_SINK"
        log "Stream $stream_id (PID $stream_pid, $app_name): Workspace $workspace → Headphones (sink $target_sink_id)"
      fi

      # Use pw-metadata to route the stream to the target sink
      ${pkgs.pipewire}/bin/pw-metadata -n default "$stream_id" target.node "$target_sink_name" 2>/dev/null || true
    }

    # Route all existing streams
    route_all_streams() {
      log "Routing all active streams..."

      # Get all stream IDs from Audio Streams section
      local stream_ids=$(${pkgs.wireplumber}/bin/wpctl status | ${pkgs.gnused}/bin/sed -n '/Audio/,/^Video/p' | ${pkgs.gnused}/bin/sed -n '/Streams:/,/^$/p' | ${pkgs.gnugrep}/bin/grep -oP '^\s+\K[0-9]+(?=\.)')

      if [ -z "$stream_ids" ]; then
        return 0
      fi

      # Get all PipeWire node info once (more efficient than per-stream)
      local pw_nodes=$(${pkgs.pipewire}/bin/pw-dump)

      # Route each stream
      for stream_id in $stream_ids; do
        # Extract stream info from cached pw-dump
        stream_pid=$(echo "$pw_nodes" | ${pkgs.jq}/bin/jq -r ".[] | select(.id == $stream_id and .type == \"PipeWire:Interface:Node\") | .info.props.\"application.process.id\" // empty")
        app_name=$(echo "$pw_nodes" | ${pkgs.jq}/bin/jq -r ".[] | select(.id == $stream_id and .type == \"PipeWire:Interface:Node\") | .info.props.\"application.name\" // \"unknown\"")

        # Fallback: if stream has no PID, try to get it from the client
        if [ -z "$stream_pid" ] || [ "$stream_pid" = "null" ] || [ "$stream_pid" = "empty" ]; then
          client_id=$(echo "$pw_nodes" | ${pkgs.jq}/bin/jq -r ".[] | select(.id == $stream_id and .type == \"PipeWire:Interface:Node\") | .info.props.\"client.id\" // empty")
          if [ -n "$client_id" ] && [ "$client_id" != "null" ] && [ "$client_id" != "empty" ]; then
            stream_pid=$(echo "$pw_nodes" | ${pkgs.jq}/bin/jq -r ".[] | select(.id == $client_id and .type == \"PipeWire:Interface:Client\") | .info.props.\"application.process.id\" // empty")
          fi
        fi

        if [ -n "$stream_pid" ] && [ "$stream_pid" != "null" ] && [ "$stream_pid" != "empty" ]; then
          route_stream "$stream_id" "$stream_pid" "$app_name"
        fi
      done
    }

    # Cleanup handler
    cleanup() {
      log "Shutting down..."
      # Kill background Hyprland monitor if still running
      if [ -n "$HYPRLAND_MONITOR_PID" ]; then
        kill "$HYPRLAND_MONITOR_PID" 2>/dev/null || true
      fi
      exit 0
    }

    trap cleanup SIGTERM SIGINT

    # Initialize
    log "Starting Hyprland workspace-based per-application audio router"
    init_sinks

    # Route all existing streams initially (with small delay for system to settle)
    sleep 1
    route_all_streams

    # Monitor Hyprland events for window/workspace changes
    (
      ${pkgs.socat}/bin/socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r event; do
        case "$event" in
          movewindow\>\>*|workspace\>\>*|focusedmon\>\>*)
            log "Hyprland event: $event - re-routing all streams"
            route_all_streams
            ;;
        esac
      done
    ) &
    HYPRLAND_MONITOR_PID=$!

    # Monitor PipeWire for new streams
    log "Monitoring PipeWire for new audio streams..."
    ${pkgs.pipewire}/bin/pw-dump --monitor | ${pkgs.jq}/bin/jq --unbuffered -r '
      select(type == "object" and .type == "PipeWire:Interface:Node" and .info.props."media.class" == "Stream/Output/Audio") |
      {id: .id, pid: .info.props."application.process.id", client_id: .info.props."client.id", name: .info.props."application.name"}
    ' | while read -r stream_json; do
      if [ -n "$stream_json" ]; then
        stream_id=$(echo "$stream_json" | ${pkgs.jq}/bin/jq -r '.id')
        stream_pid=$(echo "$stream_json" | ${pkgs.jq}/bin/jq -r '.pid // empty')
        app_name=$(echo "$stream_json" | ${pkgs.jq}/bin/jq -r '.name // "unknown"')

        # Fallback: if stream has no PID, try to get it from the client
        if [ -z "$stream_pid" ] || [ "$stream_pid" = "null" ] || [ "$stream_pid" = "empty" ]; then
          client_id=$(echo "$stream_json" | ${pkgs.jq}/bin/jq -r '.client_id // empty')
          if [ -n "$client_id" ] && [ "$client_id" != "null" ] && [ "$client_id" != "empty" ]; then
            stream_pid=$(${pkgs.pipewire}/bin/pw-dump | ${pkgs.jq}/bin/jq -r ".[] | select(.id == $client_id and .type == \"PipeWire:Interface:Client\") | .info.props.\"application.process.id\" // empty")
          fi
        fi

        if [ -n "$stream_pid" ] && [ "$stream_pid" != "null" ] && [ "$stream_pid" != "empty" ]; then
          log "New stream detected: $stream_id (PID $stream_pid, $app_name)"
          sleep 0.5  # Brief delay to ensure stream and window are ready
          route_stream "$stream_id" "$stream_pid" "$app_name"
        fi
      fi
    done
  '';

in
{
  options.services.hyprland-workspace-audio = {
    enable = mkEnableOption "Hyprland workspace-based per-application audio routing";

    tvWorkspaces = mkOption {
      type = types.listOf types.int;
      default = [ 12 ];
      description = "List of workspace numbers for TV audio output";
    };

    tvSink = mkOption {
      type = types.str;
      default = "alsa_output.pci-0000_01_00.1.hdmi-stereo";
      description = "PipeWire sink name for TV HDMI output";
    };

    headphonesSink = mkOption {
      type = types.str;
      default = "alsa_output.pci-0000_00_1f.3.analog-stereo";
      description = "PipeWire sink name for headphones output";
    };

  };

  config = mkIf cfg.enable {
    # Install required packages
    environment.systemPackages = with pkgs; [
      socat
      jq
      pipewire
      gnugrep
      gnused
    ];

    # Systemd user service
    systemd.user.services.hyprland-workspace-audio = {
      description = "Hyprland workspace-based per-application audio routing";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [ "pipewire.service" "wireplumber.service" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${daemon}";
        Restart = "on-failure";
        RestartSec = "5s";
      };

      # Only start if Hyprland is running
      unitConfig = {
        ConditionEnvironment = "HYPRLAND_INSTANCE_SIGNATURE";
      };
    };
  };
}
