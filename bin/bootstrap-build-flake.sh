#!/usr/bin/env bash
set -eu

# Check if both parameters are provided
if [ $# -ne 2 ]; then
    echo "Error: Both VM_ARCH and VM_TYPE are required."
    usage
fi

VM_ARCH="$1"
VM_TYPE="$2"

# Destroys command-line-parameters
set pipefail

# Define allowed values
ALLOWED_ARCHS=("aarch64-linux" "x86_64-linux")
ALLOWED_VM_TYPES=("vmware" "vbox")

# Helper function to join array elements with a delimiter
join_array() {
    local delimiter="$1"
    shift
    local array=("$@")
    local result=""
    for i in "${!array[@]}"; do
        if [ $i -eq 0 ]; then
            result="${array[i]}"
        else
            result="${result}${delimiter}${array[i]}"
        fi
    done
    echo "$result"
}

# Helper function to check if value is in array
contains_element() {
    local element="$1"
    shift
    local array=("$@")
    for item in "${array[@]}"; do
        if [ "$item" = "$element" ]; then
            return 0
        fi
    done
    return 1
}

# Function to display usage instructions
usage() {
    echo "Usage: $0 <VM_ARCH> <VM_TYPE>"
    echo ""
    echo "Parameters:"
    echo "  VM_ARCH     Target architecture (required)"
    echo "                  Allowed values: $(join_array ", " "${ALLOWED_ARCHS[@]}")"
    echo "  VM_TYPE  Target VM type (required)"
    echo "                  Allowed values: $(join_array ", " "${ALLOWED_VM_TYPES[@]}")"
    exit 1
}

# Validate VM_ARCH
if ! contains_element "$VM_ARCH" "${ALLOWED_ARCHS[@]}"; then
    echo "Error: Invalid VM_ARCH '$VM_ARCH'"
    echo "Allowed values: $(join_array ", " "${ALLOWED_ARCHS[@]}")"
    usage
fi

# Validate VM_TYPE
if ! contains_element "$VM_TYPE" "${ALLOWED_VM_TYPES[@]}"; then
    echo "Error: Invalid VM_TYPE '$VM_TYPE'"
    echo "Allowed values: $(join_array ", " "${ALLOWED_VM_TYPES[@]}")"
    usage
fi

export VM_ARCH
export VM_TYPE

printf "\n>>> nixos-vm: Creating a virtual machine image with the 'nixos-generators' Flake...\n"

# Enable Nix Flakes
printf "\n>>> Enabling Nix Flakes...\n"
NIX_CONF='/etc/nixos/configuration.nix'
sudo chmod u+w "$NIX_CONF"
if ! sudo grep -q 'nix.settings.experimental-features' "$NIX_CONF"; then
  sudo sed -i '/^\s*{\s*$/a\
  nix.settings.experimental-features = [ "nix-command" "flakes" ];' \
    "$NIX_CONF"
fi
sudo nixos-rebuild switch

printf "\n>>> Creating virtual machine image with Nix Flake: {arch: '${VM_ARCH}', type: '${VM_TYPE}'}\n"
nix build --refresh "github:nhooey/nixos-vm#packages.${VM_ARCH}.${VM_TYPE}"

printf "\n>>> Completed.\n\nVirtual machine images:\n-----------------------\n"
ls -sh result/nixos-image-*
