function anyfff.finder.single
  eval "$ANYFFF__FINDER_APP -p '$argv'"
end

function anyfff.finder.multiple
  eval "$ANYFFF__FINDER_APP -p '$argv' $ANYFFF__FINDER_APP_OPTION_MULTIPLE" \
    | anyfff.util.last \
    | xargs
end

