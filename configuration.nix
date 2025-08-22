{ config, pkgs, ... }:

{
  # Localization
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_CA.UTF-8";

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

  # Show IP addresses on the console login prompt (pre-login)
  # agetty expands \4 as IPv4 and \6 as IPv6 at runtime
  services.getty.helpLine = ''
    IPv4: \4
    IPv6: \6
  '';

  # Set the NixOS release to latest stable
  system.stateVersion = "25.05";
}
