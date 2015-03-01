{ config, pkgs, ... }:

{
  time.timeZone = "Pacific/Auckland";
  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "dvorak";
    defaultLocale = "en_NZ.UTF-8";
  };

  environment.systemPackages = with pkgs; [ git tmux vim wget ];

  programs.ssh.startAgent = false;
  programs.bash.enableCompletion = true;

  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;

  users.extraGroups.leroy.gid = 1000;
  users.extraUsers.leroy = {
    isNormalUser = true;
    home = "/home/leroy";
    description = "Leroy Hopson";
    extraGroups = [ "wheel" "leroy" ];
    uid = 1000;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCsJ44pUGqS8r73K0UuhTl9S7o2hENdSATug45Vb28UhuuBaiVIF8w0o7Q/sa0DhBowKB26Rre+9GJrvgglh4B3NcF/rlS9sHUAfyaAJ6bmp281buXL3FQEz4jYjfoxgX/n4aTTCfGf27eegQo/BF45aTFZEetcCQLTkh2HeihNOAMf+eUS+hDTdCvMHv2+spo9BTnogbCAy4V3Joka9tc3oskayneeY7vGhPbAMqCrI9mLRWN2f9vu8KEONEoJbhBmk8yoVW0rbICxfzNICWTJUEh4UV4R0We5eS2qhdXjSzVQf/pzQzNlOWkVL+tvi7P3KDFFrBli55qAwpE+y4qW0orao4E4f5bPcHHr5GbDQI5YN+V6DNBjT83S3t3LRafSFLGsLz1WYiAqQynDZbiigC2Kw7jzKWQ20qmwWTBQDfyhQM0JKeoyquEbCjlc7bV8vASJDPPzOe/uAVRC96FuqlGv665y+cpNEyWomFG1AyjzZAhh8e7//4F5bXbb/keQS3wnYXUq6wy0L9KYdhJzlFjySl3muZJnH8IL3vrSrI2tri/SQQwmATIM3NoMd4l9co2opchQkW2XMaVfU7yDdvt5Mkzp9/HqASjmVPW0G+aPokjyb1J+DfboeKAtwcJ/es2aRDNKIPWx2vH5r4/WzRzEgrdtHrwtz1eEN1wKDw== leroy@hilly"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC78/H0GPELM0KFIdgV4xFCeKdjJrQwXF9ZIukWd49GQu5sCrwATXVnFhihl5WKNHvr7lFgWaH1DozD6CMin6QF5WsR5/vBFmhI2wOu/SiAyyjgiK3iAOO2erL+5lXgNjfvubXjDm3noI/28ttrUWHpo6987nkpEUCNdj/GL065XjfnNXqnJTQwvptUybH9qNqMEz0/tBbHsrVEQWnabId6/BWxY2GlWTlthWm4thZXe0XaUcU/0BlzzdUDXnePO3mX3kpRRUl2T3izjiJgJt7BUDxt8X1/aQ8Ry+yDZ7fQmNlkbWLw0OtlnHkABThYjkL1qm4gyWN8KVSQAcqIWybaDdepXW6mr6zj2u+1mNKw39/NbO1vufWJJCBlKtbAAZa0qUUN36W4+9l7o/Pii8BjVwqqwh48xyPecD9jrwcBbwu4gY6O160upiFZ++LYF2yrpzLCelc+Kc2y9HJahDIbDHkMbj8AOJ/o/QvgollLu6//YNZ1QyNPtS2XMBRiLPxEpdmEb3PGqI8nhy5N7J2VqfOO826JtluAr62DMrW7+BJJa8wlJBCOUZ8HFLELOrD0FGla/fnMxqZcMYoH8yZyI1zKPZxZEV+Qt2HKSiCU4sbd6FlSPhADwGr4r/+Wf2EJeqRaEMF+S+BclsWyzhQzI554iMIs9HLFSBxkD10Xbw== leroy@zeno"
    ];
  };
  
  nix.extraOptions = ''
    auto-optimise-store = true
  '';
}
