# set proxy
set -gx HTTP_PROXY "http://127.0.0.1:7890"
export {HTTPS,FTP,RSYNC,ALL}_PROXY=$HTTP_PROXY

set -gx NO_PROXY "127.0.0.1,::1,localhost,.localdomain.com"

# haste-client
set -gx HASTE_SERVER "https://hastebin.yeufossa.org"
