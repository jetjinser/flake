## Adapter from / Credit for:
## https://github.com/MidAutumnMoon/Nuran/blob/0e5728ba622ad8578eb1c5fb53da540d7d8cd574/home/fish/tide.fish

tide configure --auto                           \
               --style=Lean                     \
               --prompt_colors='True color'     \
               --show_time=No                   \
               --lean_prompt_height='Two lines' \
               --prompt_connection=Disconnected \
               --prompt_spacing=Sparse          \
               --icons='Many icons'             \
               --transient=No

function __set_tide_variable
  set --function section "$argv[1]"
  set --function item "$argv[2]"
  set --function values $argv[3..-1]
  set -gx tide_{"$section"}_{"$item"} $values
end

#
# Prompts
#

__set_tide_variable left_prompt items \
  'pwd' 'jobs' 'git' 'newline' 'character'

__set_tide_variable jobs number_threshold 2

#
# Items
#

__set_tide_variable character icon            'λ.'
# > Bug: tide prompt shows tide_character_vi_icon_default despite fish_key_bindings being default
#   and fish_bind_mode being insert
# https://github.com/IlanCosman/tide/issues/641
__set_tide_variable character vi_icon_default 'λ.'
__set_tide_variable character vi_icon_replace 'Λ.'
__set_tide_variable character vi_icon_visual  'V.'

#
# Cleanup
#

tide reload
functions --erase __set_tide_variable
