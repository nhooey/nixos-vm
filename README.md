# nixos-vm

Generate my Nix Flake configured NixOS virtual machine with [`nixos-generators`](https://github.com/nix-community/nixos-generators).

## Creating the VM

### From Mac OS

macOS can't build Linux virtual machines with the [`nixos-generators`](https://github.com/nix-community/nixos-generators) tool, but can create a VM and run this flake on there, then rsync the file back to your main computer.

1. Download the [Minimal NixOS image for 64-bit ARM](https://channels.nixos.org/nixos-25.05/latest-nixos-minimal-aarch64-linux.iso) from the [NixOS download page](https://nixos.org/download/#nix-more).
2. Configure the VM to have 8192 MB of RAM and 4 CPUs
3. Boot the default option at the Grub boot menu
4. Run:
   ```
   URL='https://raw.githubusercontent.com/nhooey/nixos-vm/master/bin/bootstrap-build-flake.sh'
   curl -L $URL | bash -s <VM_ARCH> <VM_TYPE>`
   ```
