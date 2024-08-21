# set proxy
set -gx HTTP_PROXY "http://127.0.0.1:7890"
export {HTTPS,FTP,RSYNC,ALL}_PROXY=$HTTP_PROXY

set -gx NO_PROXY "127.0.0.1,::1,localhost,miecloud"

set GUIX_PROFILE "/home/jinser/.config/guix/current"
if test -f "$GUIX_PROFILE/etc/profile";
  fish_add_path "$GUIX_PROFILE/bin"
end
