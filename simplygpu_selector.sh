#!/bin/bash
# simplyGPU selector - A simple CLI tool to enable/disable NVIDIA GPU usage via GRUB
# Author: simplyYan
# License: CC0 1.0 Universal (Public Domain)

GRUB_FILE="/etc/default/grub"
BACKUP_FILE="/etc/default/grub.backup_$(date +%Y%m%d_%H%M%S)"
BLACKLIST_STRING="modprobe.blacklist=nouveau,nvidia,nvidia_drm,nvidia_modeset"

function check_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Use: sudo ./simplygpu-selector.sh"
    exit 1
  fi
}

function backup_grub() {
  cp "$GRUB_FILE" "$BACKUP_FILE"
  echo "✅ GRUB configuration backed up to $BACKUP_FILE"
}

function update_grub() {
  echo "🔄 Updating GRUB..."
  update-grub
  echo "✅ GRUB updated!"
}

function set_mode_intel() {
  if grep -q "$BLACKLIST_STRING" "$GRUB_FILE"; then
    echo "🟡 Intel mode is already active."
  else
    sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"\(.*\)\"/GRUB_CMDLINE_LINUX_DEFAULT=\"\1 $BLACKLIST_STRING\"/" "$GRUB_FILE"
    echo "✅ Intel mode enabled (NVIDIA disabled)."
    update_grub
  fi
}

function set_mode_nvidia() {
  if grep -q "$BLACKLIST_STRING" "$GRUB_FILE"; then
    sed -i "s/ $BLACKLIST_STRING//" "$GRUB_FILE"
    echo "✅ NVIDIA mode enabled (blacklist removed)."
    update_grub
  else
    echo "🟡 NVIDIA mode is already active."
  fi
}

function show_menu() {
  echo "┌────────────────────────────────────────────┐"
  echo "│         simplyGPU selector (CLI)           │"
  echo "│        by simplyYan - CC0 Public Domain    │"
  echo "└────────────────────────────────────────────┘"
  echo ""
  echo "Choose a GPU mode:"
  echo "  1) Enable Intel iGPU only (disable NVIDIA)"
  echo "  2) Enable NVIDIA GPU (remove blacklist)"
  echo "  3) Exit"
  echo ""
  read -p "Enter your choice [1-3]: " choice
  case "$choice" in
    1)
      backup_grub
      set_mode_intel
      ;;
    2)
      backup_grub
      set_mode_nvidia
      ;;
    3)
      echo "👋 Exiting..."
      exit 0
      ;;
    *)
      echo "❌ Invalid option."
      ;;
  esac
}

# Main
check_root
show_menu
