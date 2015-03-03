{ config, pkgs, ... }:

{
  time.timeZone = "Pacific/Auckland";
  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "dvorak";
    defaultLocale = "en_NZ.UTF-8";
  };

  environment.systemPackages = with pkgs; [
    git
    htop
    inetutils
    nmap
    telnet
    tmux
    vim
    wakelan
    wget
    unzip
  ];

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
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9RMa88ozQvtuIxjvPhxUS1AuE1jvXF/TH2GwZfUp7WHOQQsO1ZpwyZGs9RHqn056wMTrY4d6x3CgezAWL9IJ/+6oPIR/iAqdRapYu48FZUcvkAFSXVTLXD2J7OGn7VDJGlDY+M64lMEb9oDIK3KfmoN+pj07MmjmHvZK2Ms3JMpGIL9QE36HEcdeeXRcTuFX5ZWr0I+dbR+ytoVbiIOj/oy/JH27wgfrX0CRzjRSbr6se2mC6jKHt+nTWt+U9sZ946IK2J4LwWDT/7NK+bz0+6HF/3xxuvZzDKNHnB3F5wiVXsBaYSKGFfcqeQMsekhvcIFjYL36t0wPU7Iw++pQi0ga2L7x2khHXshXR0rLKM+iiID4azyrXzxwPCn7ZYy+p1aZlpOkRyE2IWirAy5edG8E2bPqQinb3djG1cml4B3jYhZt2BbiNcJQRjGo7W+XDxMs84LDduci0mbva9P2/dYxbHZ30+uJ7L1rWorDeqPYdNoai2yjMRrm1r8x6Ot0em4GsZoCKlPwfJ6hhR7C44u9gsIFtYQv+SOZkrMbDYy4pZ1jNGkZ9EQIH3h8N67pmz1bz/xW0R/Wcz+C9vHv3KYBSDwBNSB1yve0gDT7oqoYDGBbIvJfCFve3OvYxVt7LJ/dxH1+2RnP2kI4/GNfi0Un3WXxKYe8/oOJz+tbmjQ== leroy@peaches"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC78/H0GPELM0KFIdgV4xFCeKdjJrQwXF9ZIukWd49GQu5sCrwATXVnFhihl5WKNHvr7lFgWaH1DozD6CMin6QF5WsR5/vBFmhI2wOu/SiAyyjgiK3iAOO2erL+5lXgNjfvubXjDm3noI/28ttrUWHpo6987nkpEUCNdj/GL065XjfnNXqnJTQwvptUybH9qNqMEz0/tBbHsrVEQWnabId6/BWxY2GlWTlthWm4thZXe0XaUcU/0BlzzdUDXnePO3mX3kpRRUl2T3izjiJgJt7BUDxt8X1/aQ8Ry+yDZ7fQmNlkbWLw0OtlnHkABThYjkL1qm4gyWN8KVSQAcqIWybaDdepXW6mr6zj2u+1mNKw39/NbO1vufWJJCBlKtbAAZa0qUUN36W4+9l7o/Pii8BjVwqqwh48xyPecD9jrwcBbwu4gY6O160upiFZ++LYF2yrpzLCelc+Kc2y9HJahDIbDHkMbj8AOJ/o/QvgollLu6//YNZ1QyNPtS2XMBRiLPxEpdmEb3PGqI8nhy5N7J2VqfOO826JtluAr62DMrW7+BJJa8wlJBCOUZ8HFLELOrD0FGla/fnMxqZcMYoH8yZyI1zKPZxZEV+Qt2HKSiCU4sbd6FlSPhADwGr4r/+Wf2EJeqRaEMF+S+BclsWyzhQzI554iMIs9HLFSBxkD10Xbw== leroy@zeno"
    ];
  };
  
  nix.extraOptions = ''
    auto-optimise-store = true
  '';

  nix.buildCores = 0;
}
