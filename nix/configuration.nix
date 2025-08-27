{ config, pkgs, self, system, flakeInfo, nodeHostName, ... }:
{
  # Allow unfree software in nixpkgs
  nixpkgs.config.allowUnfree = true;

  # Enable Nix Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable the OpenSSH daemon and allow SSH through the firewall
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };
  networking.firewall.allowedTCPPorts = [ 22 ];

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  users.users.nixos = {
    isNormalUser = true;
    description = "NixOS user";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK2RKpJ8qQJbWwdy24pyCIcQ1awTH+3ZwtYF8OG8FCJv nixos@nixos-vm"
    ];
    extraGroups = [ "wheel" ];
  };

  environment.systemPackages = [
    pkgs.git
  ];

  services.getty.helpLine =
    let
      padRight = maxlen: str:
        let
          len = builtins.stringLength str;
          padlen = maxlen - len;
        in
        if padlen <= 0 then str
        else str + (builtins.concatStringsSep "" (builtins.genList (_: " ") padlen));
    in
    ''
      ┌──────────────────────────────────────────────────────────────┐
      │  - Hostname: ${padRight 26   nodeHostName} ${padRight 6 "Arch:"} ${system}
      │  - Flake:    ${padRight 26 flakeInfo.name} ${padRight 6 "Rev: "} ${flakeInfo.version}
      │
      │  - IPv4:     \4
      │  - IPv6:     \6
      └──────────────────────────────────────────────────────────────┘
    '';
}
