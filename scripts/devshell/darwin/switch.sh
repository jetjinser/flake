if [[ $# -lt 1 ]]; then
  echo -e "\e[31merror: missing args \`name\` and/or \`target\`\e[0m" >&2
  exit 1
fi

name=$1
mode=${2:-normal}
target=${3:-}

if [[ -e "$target" ]]; then
  echo "info: switching to $name via $target"
  if [[ "debug" == $mode ]]; then
    "$target/sw/bin/darwin-rebuild" switch --flake ".#$name" --show-trace --verbose
  else
    "$target/sw/bin/darwin-rebuild" switch --flake ".#$name"
  fi
else
  sysconf=$(build $name no-link | @jq@ -r '.[0].outputs.out')
  echo "info: switching to $name via $sysconf"
  if [[ "debug" == $mode ]]; then
    "$sysconf/sw/bin/darwin-rebuild" switch --flake ".#$name" --show-trace --verbose
  else
    "$sysconf/sw/bin/darwin-rebuild" switch --flake ".#$name"
  fi
fi
