{ config, pkgs, self, nodeHostName, ... }:
{
  networking.hostName = nodeHostName;

  # Set the NixOS release to latest stable
  system.stateVersion = "25.05";

  # Localization
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_CA.UTF-8";

  environment.systemPackages = [
    pkgs.htop
  ];

  # Enable automatic updates
  # https://nixos.wiki/wiki/Automatic_system_upgrades
  system.autoUpgrade = {
    enable = true;
    # dates = "Sun *-*-* 03:00 Europe/Stockholm";
    # randomizedDelaySec = "6hr";
    allowReboot = true;
    # Prefix: `path:` necessary to avoid confusion when using a flake inside the nix store
    flake = "path:${self.outPath}#${nodeHostName}";
    flags = [
      "--update-input"
      "nixpkgs"
      "-L" # print build logs
    ];
  };
}
