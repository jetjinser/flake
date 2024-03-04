set -l trash_path '/tmp/trash'
if not test -d $trash_path
  mkdir $trash_path
end
mv $argv[1] $trash_path
