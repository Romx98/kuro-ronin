#!/usr/bin/env bash
set -e

# ==============================================================================
# Kuro-Rōnin AST Runner - Entrypoint Script
# ==============================================================================

CONFIG_DIR="${PENTEREP_CONFIG_DIR:-/root/.penterep}"

setup_interactive_environment() {
  cat << 'EOF' > /etc/bash.bashrc
# ==============================================================================
# Kuro-Rōnin Interactive Shell Profile (Nordic Sage & Slate Palette)
# ==============================================================================

if [ -n "$PS1" ]; then
  # Color Palette Definitions (TrueColor RGB)
  CLR_PRIMARY="\033[38;2;143;171;133m"  # #8fab85 - Muted Sage Green
  CLR_TEXT="\033[38;2;227;232;229m"     # #e3e8e5 - Ash White / Primary Text
  CLR_MUTED="\033[38;2;95;107;99m"      # #5f6b63 - Slate Muted Gray
  CLR_BORDER="\033[38;2;62;71;65m"      # #3e4741 - Subtle Moss/Slate Border
  CLR_ALERT="\033[38;2;217;119;82m"     # #d97752 - Terracotta / Alert Orange
  CLR_SIGNAL="\033[38;2;76;217;100m"    # #4cd964 - Bright Signal Green
  CLR_RESET="\033[0m"

  # Stylized Muted Sage Prompt
  export PS1="\[${CLR_MUTED}\][\[${CLR_PRIMARY}\]kuro-ronin\[${CLR_MUTED}\]]\[${CLR_RESET}\]:\[${CLR_TEXT}\]\w\[${CLR_PRIMARY}\]# \[${CLR_RESET}\]"

  # Helper function to print command reference
  ronin-help() {
    echo -e "${CLR_BORDER}┌──[ ${CLR_ALERT}OPERATIONAL COMMANDS${CLR_BORDER} ]─────────────────────────────────────────┐${CLR_RESET}"
    echo -e "${CLR_BORDER}│${CLR_RESET}  ${CLR_ALERT}ptmanager --help${CLR_RESET}                         ${CLR_MUTED}Show all options and flags    ${CLR_BORDER}│${CLR_RESET}"
    echo -e "${CLR_BORDER}│${CLR_RESET}  ${CLR_ALERT}ptmanager -tl${CLR_RESET}                            ${CLR_MUTED}List all Penterep tools       ${CLR_BORDER}│${CLR_RESET}"
    echo -e "${CLR_BORDER}│${CLR_RESET}  ${CLR_ALERT}ptmanager -pl${CLR_RESET}                            ${CLR_MUTED}List registered projects      ${CLR_BORDER}│${CLR_RESET}"
    echo -e "${CLR_BORDER}│${CLR_RESET}  ${CLR_ALERT}ptmanager -pn -T <url> -a <token>${CLR_RESET}        ${CLR_MUTED}Register a new project on AS  ${CLR_BORDER}│${CLR_RESET}"
    echo -e "${CLR_BORDER}│${CLR_RESET}  ${CLR_ALERT}ptmanager -ps <id>${CLR_RESET}                       ${CLR_MUTED}Start project connection      ${CLR_BORDER}│${CLR_RESET}"
    echo -e "${CLR_BORDER}│${CLR_RESET}  ${CLR_ALERT}ptmanager -pe <id>${CLR_RESET}                       ${CLR_MUTED}Terminate project connection  ${CLR_BORDER}│${CLR_RESET}"
    echo -e "${CLR_BORDER}│${CLR_RESET}  ${CLR_PRIMARY}ronin-status${CLR_RESET}                             ${CLR_MUTED}Print live diagnostics        ${CLR_BORDER}│${CLR_RESET}"
    echo -e "${CLR_BORDER}└─────────────────────────────────────────────────────────────────────────┘${CLR_RESET}"
  }

  # Helper function to print live diagnostics
  ronin-status() {
    local py_ver
    local pt_ver
    local proj_count
    local host_ip

    py_ver="$(python3 -V 2>&1 | cut -d' ' -f2)"
    pt_ver="$(ptmanager --version 2>/dev/null || echo 'active')"
    proj_count="$(ptmanager -pl 2>&1 | grep -c 'ID' 2>/dev/null | tr -d '\n\r' || true)"
    proj_count="${proj_count:-0}"
    host_ip="$(hostname -I 2>/dev/null | awk '{print $1}')"
    host_ip="${host_ip:-127.0.0.1}"

    echo -e "${CLR_BORDER}┌──[ ${CLR_PRIMARY}SYSTEM DIAGNOSTICS${CLR_BORDER} ]${CLR_RESET}"
    echo -e "${CLR_BORDER}│${CLR_RESET}  ${CLR_SIGNAL}●${CLR_RESET} ${CLR_MUTED}Host IPv4:${CLR_RESET}          ${CLR_TEXT}${host_ip}${CLR_RESET}"
    echo -e "${CLR_BORDER}│${CLR_RESET}  ${CLR_SIGNAL}●${CLR_RESET} ${CLR_MUTED}Python Runtime:${CLR_RESET}     ${CLR_TEXT}v${py_ver}${CLR_RESET}"
    echo -e "${CLR_BORDER}│${CLR_RESET}  ${CLR_SIGNAL}●${CLR_RESET} ${CLR_MUTED}ptmanager Core:${CLR_RESET}     ${CLR_TEXT}${pt_ver}${CLR_RESET}"
    echo -e "${CLR_BORDER}│${CLR_RESET}  ${CLR_SIGNAL}●${CLR_RESET} ${CLR_MUTED}Network Mode:${CLR_RESET}       ${CLR_TEXT}Host Mode (NET_RAW + NET_ADMIN)${CLR_RESET}"
    echo -e "${CLR_BORDER}│${CLR_RESET}  ${CLR_SIGNAL}●${CLR_RESET} ${CLR_MUTED}Registered Audits:${CLR_RESET}  ${CLR_ALERT}${proj_count}${CLR_RESET}"
    echo -e "${CLR_BORDER}│${CLR_RESET}  ${CLR_SIGNAL}●${CLR_RESET} ${CLR_MUTED}Persistent Store:${CLR_RESET}   ${CLR_TEXT}/root/.penterep${CLR_RESET}"
    echo -e "${CLR_BORDER}└─────────────────────────────${CLR_RESET}"
  }

  # Display Muted Sage banner on interactive login
  echo -e "${CLR_PRIMARY}"
  cat << 'BANNER'
    __ __                 ____              _     
   / //_/_  ___________  / __ \____  ____  (_)___ 
  / ,< / / / / ___/ __ \/ /_/ / __ \/ __ \/ / __ \
 / /| / /_/ / /  / /_/ / _, _/ /_/ / / / / / / / /
/_/ |_\__,_/_/   \____/_/ |_|\____/_/ /_/_/_/ /_/ 
BANNER
  echo -e "${CLR_MUTED}           [ Penterep AST Runner & Security Arsenal ]${CLR_RESET}"
  echo ""
  ronin-status
  echo ""
  ronin-help
  echo ""
fi
EOF
}

setup_interactive_environment

mkdir -p "${CONFIG_DIR}"

# Execute container command
exec "$@"
