# https://lobste.rs/s/ahmi0i/quick_bits_realise_nix_symlinks#c_cajper

set -l item
for item in $argv
  if test ! -L $item
    continue
  end

  set -l bak (dirname $item)/.(basename $item).hijack.bak
  set -l tmp (string replace .bak .tmp $bak)

  cp --no-dereference --remove-destination $item $bak; or return $status

  rm -rf $tmp; or return $status
  cp -r (readlink --canonicalize $item) $tmp; or return $status
  chmod -R u+w $tmp; or return $status

  rm $item; or return $status

  mv $tmp $item; or return $status
end

$EDITOR -- $argv
set -l ret $status

for item in $argv
  set -l bak (dirname $item)/.(basename $item).hijack.bak

  if test ! -e $bak
    continue
  end

  mv $bak $item; or return $status
end

return $ret
