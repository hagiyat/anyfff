function anyfff.cdr -d 'Returns the merged directory of the directory around the current directory and the history of cd'
  begin
    cat $ANYFFF__CDR_HISTORIES_PATH \
      | anyfff.cdr.filter_pwd \
      | anyfff.cdr.add_mark $ANYFFF__CDR_HISTORIES_MARK \
      | anyfff.util.reverse
    anyfff.cdr.get_dirs (realpath "$PWD/..") \
      | anyfff.cdr.filter_pwd \
      | anyfff.cdr.add_mark $ANYFFF__CDR_SIBLINGS_MARK \
      | anyfff.util.reverse
    anyfff.cdr.get_dirs $PWD \
      | anyfff.cdr.filter_pwd \
      | anyfff.cdr.add_mark $ANYFFF__CDR_BRANCHES_MARK \
      | anyfff.util.reverse
    anyfff.cdr.root_dirs \
      | anyfff.cdr.filter_pwd \
      | anyfff.cdr.add_mark $ANYFFF__CDR_ROOT_MARK \
      | anyfff.util.reverse
  end
end

function anyfff.cdr.register --on-variable PWD
  anyfff.cdr.append_cd_history &
  anyfff.cdr.update_cache (realpath "$PWD/..") &
  anyfff.cdr.update_cache (realpath $PWD) &
  fish -c anyfff.cdr.clear_cache &
end

function anyfff.cdr.clear_cache
  find $ANYFFF__CDR_CACHE_PATH -type f \
    -atime "+$ANYFFF__CDR_CACHE_LIFETIME" \
    ! -name $ANYFFF__CDR_HISTORIES_FILE \
    | xargs rm -f ^/dev/null
end

function anyfff.cdr.force_clear_caches -d 'remove all cd histories'
  find $ANYFFF__CDR_CACHE_PATH -type f \
    ! -name $ANYFFF__CDR_HISTORIES_FILE \
    | xargs rm -f ^/dev/null
end

function anyfff.cdr.append_cd_history
  pwd >> $ANYFFF__CDR_HISTORIES_PATH
  cat $ANYFFF__CDR_HISTORIES_PATH \
    | anyfff.util.reverse \
    | anyfff.util.unique \
    | anyfff.util.reverse \
    > $ANYFFF__CDR_HISTORIES_PATH
end

function anyfff.cdr.root_dirs
  echo '/'
  pwd \
    | string split '/' \
    | sed 1,1d \
    | awk '{v=sprintf("%s/%s", v, $0); print v;}'
end

function anyfff.cdr.update_cache -a _dir
  set -l name_hash (anyfff.cdr.checksum $_dir)
  set -l dir_hash (anyfff.cdr.checksum (ls $_dir))
  set -l target_file (printf "%s/%s.log" $ANYFFF__CDR_CACHE_PATH $name_hash)

  if anyfff.cdr.is_match_checksum $dir_hash $target_file
    anyfff.cdr.push_log "[found] $_dir -> $target_file"
  else
    anyfff.cdr.push_log "[generate] $_dir -> $target_file"

    touch $target_file
    echo $dir_hash > $target_file
    find $_dir -type d -depth 1 -user $USER -perm -u+r ^/dev/null \
      | xargs realpath \
      >> $target_file
  end
end

function anyfff.cdr.push_log -a message
  if set -q ANYFFF__CDR_ACTIVITY_PATH
    echo $message >> $ANYFFF__CDR_ACTIVITY_PATH
  end
end

function anyfff.cdr.get_dirs -a _dir
  set -l name_hash (anyfff.cdr.checksum $_dir)
  set -l dir_hash (anyfff.cdr.checksum (ls $_dir))
  set -l target_file (printf "%s/%s.log" $ANYFFF__CDR_CACHE_PATH $name_hash)

  if not anyfff.cdr.is_match_checksum $dir_hash $target_file
    anyfff.cdr.update_cache $_dir
  end

  cat $target_file | sed 1,2d
end

function anyfff.cdr.filter_pwd
  awk -v pwd="$PWD" '$1!=pwd {print}'
end

function anyfff.cdr.add_mark -a mark
  sed -e "s/^/$mark /g"
end

function anyfff.cdr.checksum -a v
  echo $v | eval $ANYFFF__CHECKSUM_APP | anyfff.util.first
end

function anyfff.cdr.is_match_checksum -a dir_hash file_name
  if not test -e $file_name
    return 1
  end

  set -l hash_value (head -n 1 $file_name)
  return ([ $hash_value = $dir_hash ])
end
