target=""
buildFlags=()
buildFlags+=("-l")
rebuildFlags=()

OPTSTRING=":pn:t:d"
while getopts ${OPTSTRING} opt; do
  case ${opt} in
    # pretty
    p)
      buildFlags+=("-p")
      ;;
    # name
    n)
      name=$OPTARG
      ;;
    # target
    t)
      target=$OPTARG
      ;;
    # debug
    d)
      buildFlags+=("-d")
      rebuildFlags+=("--show-trace" "--verbose")
      ;;
    :)
      echo "Option -${OPTARG} requires an argument." >&2
      exit 1
      ;;
    ?)
      echo "Invalid option: -${OPTARG}" >&2
      exit 1
      ;;
  esac
done

if [[ -e "$target" ]]; then
  echo "info: switching to $name using $target with flags: ${rebuildFlags[@]}" >&2

  "$target/sw/bin/darwin-rebuild" switch "${rebuildFlags[@]}" --flake ".#$name"
else
  echo "info: building $name with build flags ${buildFlags[@]}" >&2

  sysconf=$(build -n $name "${buildFlags[@]}" | @JQ@ -r '.[0].outputs.out')

  echo "info: switching to $name using $sysconf with rebuild flags ${rebuildFlags[@]}" &>2

  "$sysconf/sw/bin/darwin-rebuild" switch "${rebuildFlags[@]}" --flake ".#$name"
fi
