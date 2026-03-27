hyprctl binds -j | jq -r '
  def hasbit($m): ((.modmask / $m | floor) % 2) == 1;

  def mods:
    [
      if hasbit(64) then "SUPER" else empty end,
      if (hasbit(1) or hasbit(2))  then "SHIFT" else empty end,
      if (hasbit(4) or hasbit(16)) then "CTRL"  else empty end,
      if (hasbit(8) or hasbit(32)) then "ALT"   else empty end
    ] | join("+") | if . == "" then "NONE" else . end;

  def key:
    (.key // (.keycode|tostring) // "?");

  def clean:
    gsub("[\t\n\r]+"; " ") | gsub(" +"; " ");

  .. | objects |
  select(has("dispatcher")) |

  (((.description // "") | clean)) as $desc |
  ((.dispatcher + "(" + ((.arg // "") | clean) + ")")) as $cmd |

  [
    (mods + " + " + key),
    (if $desc != "" then $desc else $cmd end),
    (if $desc != "" then "" else $cmd end)
  ] | @tsv
' |
  sed -E 's|/nix/store/[a-z0-9]{32}-||g' |
  sort -u |
  awk -F '\t' '{
    keys = $1
    main = $2
    side = $3
    
    # Define Colors
    c_key = "\033[1;36m"
    c_arrow = "\033[0;33m"
    c_reset = "\033[0m"

    # Print with fixed widths for the text, injecting colors around them
    # This ensures the arrows (→) always line up regardless of color codes
    printf " %s%-28s%s  %s→%s  %s%-50s%s\n", 
           c_key, keys, c_reset, 
           c_arrow, c_reset, 
           c_reset, main, c_reset
}'
