{ config, pkgs, user, ... }:

{
  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Ensure LightDM can see the Hyprland session
  services.displayManager.sessionPackages = [ pkgs.hyprland ];

  # Wayland-specific packages
  environment.systemPackages = with pkgs; [
    # Screenshot tool (replaces scrot)
    grim
    slurp

    # Clipboard (replaces xclip)
    wl-clipboard

    # Screen locker
    swaylock

    # App launcher (replaces dmenu) - rofi now supports both X11 and Wayland
    rofi

    # Cursor barrier for multi-monitor
    wayland-utils
    wlr-randr # Display management (replaces xrandr)

    # Notification daemon
    mako

    # Wallpaper
    swaybg

    # Idle management
    swayidle

    # Monitor mirroring
    wl-mirror

    # Gaming: gamescope for better Steam rendering
    gamescope
  ];

  # Note: LightDM (from workstation/default.nix) will show Hyprland as a session option
  # No need to replace the display manager - both XMonad and Hyprland will be available

  # XDG portal for screen sharing, file pickers, etc.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  home-manager.users.${user.name} = { lib, pkgs, ... }: {
    # Mako notification daemon configuration
    services.mako = {
      enable = true;
      settings = {
        default-timeout = 5000; # Auto-dismiss after 5 seconds
        background-color = "#1e1e1e";
        text-color = "#ffffff";
        border-color = "#50404D";
        border-size = 2;
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;

      # Main Hyprland configuration
      settings = {
        # Monitors: iGPU + NVIDIA discrete GPU
        monitor = [
          # iGPU DisplayPort - HKM DL2789UB-Pro (27" 4K @ 74.62Hz) at 3840,0 with 1.5x scaling and many workspaces
          "DP-5,3840x2160@74.62,3840x0,1.5"

          # iGPU HDMI - Beyond TV (4K @ 144Hz) at position 0,0 with single workspace
          "HDMI-A-5,3840x2160@144,0x0,1.5"

          # Disable old NVIDIA HDMI (TV no longer connected here)
          "HDMI-A-1,disable"

          # Disable unused discrete GPU ports
          "DP-1,disable" # iGPU DisplayPort (no longer used)
          "HDMI-A-4,disable" # Additional discrete GPU ports
          "HDMI-A-3,disable"
          "HDMI-A-2,disable"
          "DP-2,disable"
          "DP-3,disable"
          "DP-4,disable"
        ];

        # Workspace assignments: 1-11 on DP-5 (desktop monitor), 12 on HDMI-A-5 (TV)
        workspace =
          (builtins.genList (i: "${toString (i + 1)}, monitor:DP-5") 11)
          ++ [
            "12, monitor:HDMI-A-5" # TV workspace (Beyond TV on iGPU)
          ];

        # Input configuration
        input = {
          kb_layout = "us,us"; # Two layouts: both US
          kb_variant = "dvp,"; # First with dvp variant, second with default (qwerty)
          kb_options = "altwin:swap_ralt_rwin"; # Make Right Alt act as Super (Win key)

          follow_mouse = 1; # Focus follows mouse cursor

          #touchpad = {
          #  natural_scroll = false;
          #};
        };

        # General settings
        general = {
          #gaps_in = 0; # Match XMonad's no-gaps default
          #gaps_out = 0;
          #border_size = 3; # Thicker border for 4K visibility

          layout = "master"; # Master-stack layout like XMonad

          resize_on_border = true;
        };

        # Decorations
        #decoration = {
        #  rounding = 0;

        #  blur = {
        #    enabled = false;
        #  };
        #};

        ## Animations
        #animations = {
        #  enabled = false;
        #};

        # Master layout configuration
        master = {
          #new_status = "master"; # New windows go to stack (like xmonad)
          #mfact = 0.5; # Master area factor (50/50 split)
          #new_on_top = false; # New slaves added at bottom of stack
          # Note: orientation is set to "left" (Tall) in exec-once below
        };

        # Cursor barrier for TV - confine cursor to desktop monitor by default
        # You can toggle this with a keybinding
        cursor = {
          no_warps = false; # Allow cursor warping between monitors when switching focus
        };

        # Window rules
        windowrule = [
          # Remove borders in monocle/maximize mode (fullscreen state 1)
          "border_size 0, match:fullscreen_state_internal 1"

          # TV workspace - everything fullscreen
          "fullscreen on, match:workspace 12"

          # Kodi always on TV
          "workspace 12, match:class ^(kodi)$"

          # Steam big picture on TV
          "workspace 12, match:title ^(Steam Big Picture Mode)$"
        ];

        # Keybindings
        # Using Right Alt (swapped with Right Win, so acts as Super) as main modifier
        "$mainMod" = "SUPER";

        bind = [
          # Terminal
          "$mainMod, T, exec, kitty"

          # App launcher
          "$mainMod, R, exec, rofi -show run"

          # Kill focused window
          "$mainMod SHIFT, C, killactive"

          # Cycle through layouts like xmonad (Tall, Wide, Full)
          # Uses state file since orientation changes aren't reflected in getoption
          #"$mainMod, SPACE, exec, ${pkgs.writeShellScript "cycle-layout" ''
          #  STATE_FILE="/tmp/hyprland-layout-$USER-$(${pkgs.hyprland}/bin/hyprctl activeworkspace -j | ${pkgs.jq}/bin/jq -r '.id')"

          #  # Initialize if doesn't exist
          #  [ -f "$STATE_FILE" ] || echo "tall" > "$STATE_FILE"

          #  # Read current state
          #  current=$(cat "$STATE_FILE")

          #  # Cycle: tall -> wide -> full -> tall
          #  case "$current" in
          #    tall)
          #      ${pkgs.hyprland}/bin/hyprctl dispatch layoutmsg orientationtop
          #      echo "wide" > "$STATE_FILE"
          #      ;;
          #    wide)
          #      ${pkgs.hyprland}/bin/hyprctl dispatch fullscreen 1
          #      echo "full" > "$STATE_FILE"
          #      ;;
          #    full)
          #      ${pkgs.hyprland}/bin/hyprctl dispatch fullscreen 1
          #      ${pkgs.hyprland}/bin/hyprctl dispatch layoutmsg orientationleft
          #      echo "tall" > "$STATE_FILE"
          #      ;;
          #    *)
          #      # Unknown state, reset to tall
          #      ${pkgs.hyprland}/bin/hyprctl dispatch layoutmsg orientationleft
          #      echo "tall" > "$STATE_FILE"
          #      ;;
          #  esac
          #''}"

          # Reset to default layout (like xmonad's Alt+Shift+Space)
          #"$mainMod SHIFT, SPACE, exec, ${pkgs.writeShellScript "reset-layout" ''
          #  STATE_FILE="/tmp/hyprland-layout-$USER-$(${pkgs.hyprland}/bin/hyprctl activeworkspace -j | ${pkgs.jq}/bin/jq -r '.id')"

          #  # Exit fullscreen if active
          #  active_window=$(${pkgs.hyprland}/bin/hyprctl activewindow -j 2>/dev/null || echo '{}')
          #  is_maximized=$(echo "$active_window" | ${pkgs.jq}/bin/jq -r '.fullscreen // false')
          #  if [ "$is_maximized" = "true" ] || [ "$is_maximized" = "1" ]; then
          #    ${pkgs.hyprland}/bin/hyprctl dispatch fullscreen 1
          #  fi

          #  # Reset to Tall layout
          #  ${pkgs.hyprland}/bin/hyprctl dispatch layoutmsg orientationleft
          #  echo "tall" > "$STATE_FILE"
          #''}"

          # Focus movement (u/e for down/up, matching your Dvorak bindings)
          "$mainMod, U, layoutmsg, cyclenext"
          "$mainMod, E, layoutmsg, cycleprev"
          #"$mainMod, TAB, layoutmsg, cyclenext"
          "$mainMod, M, layoutmsg, focusmaster"

          # Window swapping
          "$mainMod, RETURN, layoutmsg, swapwithmaster"
          "$mainMod SHIFT, J, layoutmsg, swapnext"
          "$mainMod SHIFT, K, layoutmsg, swapprev"

          # Master area resize (h/s for shrink/expand)
          "$mainMod, H, splitratio, -0.05"
          "$mainMod, S, splitratio, +0.05"

          # Float/tile toggle
          "$mainMod, C, togglefloating"

          # Fullscreen toggle
          "$mainMod, SPACE, fullscreen, 0"

          # Increment/decrement master windows
          "$mainMod, I, layoutmsg, addmaster"
          "$mainMod, D, layoutmsg, removemaster"

          # Quit/restart Hyprland
          "$mainMod SHIFT, Q, exit"
          "$mainMod, Q, exec, hyprctl reload"

          # Switch to workspaces (programmer dvorak keys: &*(){}+[]!=)
          # These map to number row: 1234567890-
          "$mainMod, ampersand, workspace, 1" # & key (shift+7 on dvorak)
          "$mainMod, asterisk, workspace, 2" # * key (shift+8)
          "$mainMod, parenleft, workspace, 3" # ( key (shift+9)
          "$mainMod, parenright, workspace, 4" # ) key (shift+0)
          "$mainMod, braceright, workspace, 5" # } key (shift+])
          "$mainMod, plus, workspace, 6" # + key (shift+=)
          "$mainMod, braceleft, workspace, 7" # { key (shift+[)
          "$mainMod, bracketright, workspace, 8" # ] key
          "$mainMod, bracketleft, workspace, 9" # [ key
          "$mainMod, exclam, workspace, 10" # ! key (shift+1)
          "$mainMod, equal, workspace, 11" # = key

          # Move window to workspace (same keys with shift)
          "$mainMod SHIFT, ampersand, movetoworkspace, 1"
          "$mainMod SHIFT, asterisk, movetoworkspace, 2"
          "$mainMod SHIFT, parenleft, movetoworkspace, 3"
          "$mainMod SHIFT, parenright, movetoworkspace, 4"
          "$mainMod SHIFT, braceright, movetoworkspace, 5"
          "$mainMod SHIFT, plus, movetoworkspace, 6"
          "$mainMod SHIFT, braceleft, movetoworkspace, 7"
          "$mainMod SHIFT, bracketright, movetoworkspace, 8"
          "$mainMod SHIFT, bracketleft, movetoworkspace, 9"
          "$mainMod SHIFT, exclam, movetoworkspace, 10"
          "$mainMod SHIFT, equal, movetoworkspace, 11"

          # Switch monitors (y/g for screens, matching your config)
          "$mainMod, Y, focusmonitor, DP-5" # Desktop monitor (nvidia DisplayPort)
          "$mainMod, G, focusmonitor, HDMI-A-5" # TV (iGPU HDMI)

          # Move window to monitor
          "$mainMod SHIFT, Y, movewindow, mon:DP-5" # Move to desktop monitor
          "$mainMod SHIFT, G, movewindow, mon:HDMI-A-5" # Move to TV

          # Screenshot (replaces scrot)
          "$mainMod SHIFT, S, exec, grim -g \"$(slurp)\" ~/screenshot-$(date +%Y%m%d-%H%M%S).png"

          # Lock screen
          "$mainMod, L, exec, swaylock -f -c 000000"

          # TV preview window
          "$mainMod, P, exec, wl-mirror HDMI-A-5"

          # Keyboard layout toggle (matching your XMonad binding)
          "$mainMod SHIFT, A, exec, ${pkgs.writeShellScript "toggle-layout" ''
            # Get all keyboard devices and switch each one
            ${pkgs.hyprland}/bin/hyprctl devices -j | ${pkgs.jq}/bin/jq -r '.keyboards[].name' | while read -r device; do
              ${pkgs.hyprland}/bin/hyprctl switchxkblayout "$device" next
            done
          ''}"
        ];

        # Mouse bindings
        bindm = [
          "$mainMod, mouse:272, movewindow" # Alt + left click to move
          "$mainMod, mouse:273, resizewindow" # Alt + right click to resize
        ];

        # XWayland settings - fix for fractional scaling issues
        xwayland = {
          force_zero_scaling = true; # XWayland apps render at scale 1, then upscaled by compositor
        };

        # Misc settings
        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          mouse_move_enables_dpms = true;
          key_press_enables_dpms = true;
          vrr = 0; # Variable refresh rate off by default
          exit_window_retains_fullscreen = true; # Keep fullscreen when nested fullscreen app closes
        };

        # Debug settings
        debug = {
          disable_logs = false;
          enable_stdout_logs = true;
        };

        # Environment variables for Intel iGPU primary
        env = [
          "WLR_DRM_DEVICES,/dev/dri/card1" # Force primary Intel GPU (not SR-IOV VFs)
          "LIBVA_DRIVER_NAME,iHD" # Use Intel QuickSync for video decode
          "XDG_SESSION_TYPE,wayland"
          "MOZ_ENABLE_WAYLAND,1" # Enable Wayland for Firefox

          # Better font rendering for XWayland apps (HiDPI for 4K)
          # For 1.5x scaling: render at 2x then scale down by 0.75
          "GDK_SCALE,2"
          "GDK_DPI_SCALE,0.75"
          "QT_AUTO_SCREEN_SCALE_FACTOR,1"

          # Steam-specific fixes for better rendering
          "STEAM_FORCE_DESKTOPUI_SCALING,2"
        ];
      };

      # Startup applications
      extraConfig = ''
        # Enable debug logging to file
        exec-once = hyprctl keyword debug:enable_stdout_logs true

        # Force Tall layout (orientation left) on startup
        exec-once = hyprctl keyword master:orientation left

        # Set default workspace on startup
        exec-once = hyprctl dispatch workspace 2

        # Start wallpaper (waybar removed for now)
        exec-once = swaybg -i ~/wallpaper.png -m fill

        # Start fcitx5 for input method
        exec-once = fcitx5 -d

        # Cursor barrier script for TV monitor
        # This prevents cursor from going to TV unless explicitly switched
        exec-once = ${pkgs.writeShellScript "cursor-barrier" ''
          # This would need a custom implementation for Hyprland
          # For now, we rely on manual monitor switching with Alt+G/Y
        ''}
      '';
    };
  };
}
