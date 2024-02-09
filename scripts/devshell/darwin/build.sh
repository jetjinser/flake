builder="nix"
extraFlags=()

OPTSTRING=":pn:dl"
while getopts ${OPTSTRING} opt; do
  case ${opt} in
  # pretty
  p)
    builder="@NOM@"
    ;;
  # name
  n)
    name=$OPTARG
    ;;
  # debug
  d)
    extraFlags+=("--show-trace" "--verbose")
    ;;
  # no-link
  l)
    extraFlags+=("--json" "--no-link")
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

flakeFlags=(--extra-experimental-features 'nix-command flakes')
target=".#darwinConfigurations.$name.system"

echo "info: build $target using $builder with flags ${extraFlags[@]}" >&2

$builder build "${flakeFlags[@]}" "${extraFlags[@]}" $target
