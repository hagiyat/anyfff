# Usage:
# single select> __anyfff_finder -s 'prompt message > '
# multiple select> __anyfff_finder -m 'prompt message[multi] > '
function __anyfff_finder -a single_or_multi prompt
  if [ $single_or_multi = '-s' ]
    eval "$ANYFFF__FINDER_APP --prompt '$prompt'"

  else
    eval "$ANYFFF__FINDER_APP --prompt '$prompt' $ANYFFF__FINDER_APP_OPTION_MULTIPLE" \
      | __anyfff_util last \
      | xargs
  end
end

