{ config, pkgs, ... }:

{
  # Localization
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_CA.UTF-8";

  # Allow unfree software in nixpkgs
  nixpkgs.config.allowUnfree = true;

  # Enable the OpenSSH daemon and allow SSH through the firewall
  services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  users.users.nixos = {
    isNormalUser = true;
    description = "NixOS user";
    hashedPassword = "$6$XpJJEDcGVilE/WPF$BvTFYs/bXL25yiaCY/4dgwTWn82rMGKAi6CgRcQkDp9yINgpLxOGDFZpZtItvRFwCcNwypC5sll7mn/mNW14R/";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK2RKpJ8qQJbWwdy24pyCIcQ1awTH+3ZwtYF8OG8FCJv nixos@nixos-vm"
    ];
  };

  environment.systemPackages = [
    pkgs.git
  ];

  # Set the NixOS release to latest stable
  system.stateVersion = "25.05";
}
