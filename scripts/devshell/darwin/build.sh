if [[ $# -lt 1 ]]; then
  echo -e "\e[31merror: missing args \`name\` and \`mode\`\e[0m" >&2
  exit 1
fi

name=$1
mode=$2

flakeFlags=(--extra-experimental-features 'nix-command flakes')

target=".#darwinConfigurations.$name.system"
if [[ "debug" == $mode ]]; then
    @nom@ build "${flakeFlags[@]}" $target --show-trace --verbose
elif [[ "nom" == $mode ]]; then
    @nom@ build "${flakeFlags[@]}" $target
elif [[ "no-link" == $mode ]]; then
    nix build "${flakeFlags[@]}" $target --json --no-link
else
    nix build "${flakeFlags[@]}" $target
fi
