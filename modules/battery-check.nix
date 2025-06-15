{ threshold, pkgs, ... }:

{
  # Add a cron job to check the battery status and automatically suspend the system
  # when it is charged percent is lower than the given threshold.
  services.cron =
    let
      script = with pkgs; writeText "battery-check" ''
        #!/bin/sh
        ${acpi}/bin/acpi -b | ${gawk}/bin/awk -F'[,:%]' '{print $2, $3}' | {
            read -r status capacity

            # Ignore batteries at 0% (fake or too late).
            if [ "$capacity" -eq 0 ]; then
              exit 0
            fi

            if [ "$status" = Discharging -a "$capacity" -lt ${toString threshold} ]; then
                ${busybox}/bin/logger "Critical battery threshold"
                ${systemd}/bin/systemctl suspend
            fi
        }
      '';
    in
    {
      enable = true;
      systemCronJobs = [
        "*/1 * * * * root /bin/sh ${script}"
      ];
    };
}
