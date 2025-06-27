{ inputs, ... }: self: super:
let
  secrets = import "${inputs.secrets}/secrets.nix";
in
{
  golden-cheetah = super.golden-cheetah.overrideAttrs (old: rec {
    preConfigure = old.preConfigure + ''
      # Enable Strava support (https://github.com/GoldenCheetah/GoldenCheetah/wiki/Strava-configuration).
      echo 'DEFINES += GC_STRAVA_CLIENT_ID=\\\"166104\\\"' >> src/gcconfig.pri
      echo 'DEFINES += GC_STRAVA_CLIENT_SECRET=\\\"${secrets.stravaClientSecret}\\\"' >> src/gcconfig.pri
    '';
  });
}
