set -q HASTE_SERVER
and set -f server "$HASTE_SERVER"
or set -f server 'https://hastebin.yeufossa.org'

if isatty stdin
  set -f json (curl -s "$server/documents" --data-binary @$argv)
else
  cat $argv 2>/dev/null | read -l -z content
  set -f json (curl -s "$server/documents" --data-binary $content)
end

echo $json | sed "s|{\"key\"\:\"\(.*\)\"}|$server/\1\n|"
