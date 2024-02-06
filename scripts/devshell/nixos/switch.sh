if [[ $# -lt 1 ]]; then
  echo -e "\e[31merror: missing args \`name\` and/or \`mode\`\e[0m" >&2
  exit 1
fi

name=$1
mode=${2:-"normal"}

echo "info: switching to $name in $mode mode"

if [[ "debug" == $mode ]]; then
  @nom@ build ".#nixosConfigurations.$name.config.system.build.toplevel" --show-trace --verbose --no-link
  nixos-rebuild switch --use-remote-sudo --flake ".#$name" --show-trace --verbose
elif [[ "nom" == $mode ]]; then
  @nom@ build ".#nixosConfigurations.$name.config.system.build.toplevel" --no-link
  nixos-rebuild switch --use-remote-sudo --flake ".#$name"
else
  nixos-rebuild switch --use-remote-sudo --flake ".#$name"
fi
