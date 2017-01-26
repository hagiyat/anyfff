function anyfff.context_file_search
  commandline | read -l cl
  if git_is_repo and string match -q 'git' $cl
    if anyfff.context_file_search.belongs_to_tracked_file $cl
      git status --short
    else
      git ls-files
    end
  else
    find . -maxdepth $ANYFFF__FILESEARCH_MAXDEPTH -type f \
      | anyfff.util.last
  end
end

function anyfff.context_file_search.belongs_to_tracked_file -a cmd
  set -l conditions 'git +add' 'git +checkout' 'git +reset'
  for c in $conditions
    if string match -q -r $c $cmd
      return 0
    end
  end
  return 1
end
