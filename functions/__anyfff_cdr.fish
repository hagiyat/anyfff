function __anyfff_cdr -d 'Returns the merged directory of the directory around the current directory and the history of cd'
  begin
    cat $ANYFFF__CDR_HISTORIES_PATH \
      | __cdr_filter_pwd \
      | __cdr_add_mark $ANYFFF__CDR_HISTORIES_MARK \
      | __anyfff_util reverse
    __cdr_get_dirs (realpath "$PWD/..") \
      | __cdr_filter_pwd \
      | __cdr_add_mark $ANYFFF__CDR_SIBLINGS_MARK \
      | __anyfff_util reverse
    __cdr_get_dirs $PWD \
      | __cdr_filter_pwd \
      | __cdr_add_mark $ANYFFF__CDR_BRANCHES_MARK \
      | __anyfff_util reverse
    __cdr_root_dirs \
      | __cdr_filter_pwd \
      | __cdr_add_mark $ANYFFF__CDR_ROOT_MARK \
      | __anyfff_util reverse
  end
end

function __cdr_register --on-variable PWD
  __cdr_append_cd_history &
  __cdr_update_cache (realpath "$PWD/..") &
  __cdr_update_cache (realpath $PWD) &
  fish -c __cdr_clear_cache &
end

function __cdr_clear_cache
  find $ANYFFF__CDR_CACHE_PATH -type f \
    -atime "+$ANYFFF__CDR_CACHE_LIFETIME" \
    ! -name $ANYFFF__CDR_HISTORIES_FILE \
    | xargs rm -f ^/dev/null
end

function __cdr_append_cd_history
  pwd >> $ANYFFF__CDR_HISTORIES_PATH
  cat $ANYFFF__CDR_HISTORIES_PATH \
    | __anyfff_util reverse \
    | __anyfff_util unique \
    | __anyfff_util reverse \
    > $ANYFFF__CDR_HISTORIES_PATH
end

function __cdr_root_dirs
  echo '/'
  pwd \
    | string split '/' \
    | sed 1,1d \
    | awk '{v=sprintf("%s/%s", v, $0); print v;}'
end

function __cdr_update_cache -a _dir
  set -l name_hash (__cdr_checksum $_dir)
  set -l dir_hash (__cdr_checksum (ls $_dir))
  set -l target_file (printf "%s/%s.log" $ANYFFF__CDR_CACHE_PATH $name_hash)

  if __cdr_is_match_checksum $dir_hash $target_file
    __cdr_push_log "[found] $_dir -> $target_file"
  else
    __cdr_push_log "[generate] $_dir -> $target_file"

    touch $target_file
    echo $dir_hash > $target_file
    find $_dir -type d -depth 1 -user $USER -perm -u+r ^/dev/null \
      | xargs realpath \
      >> $target_file
  end
end

function __cdr_push_log -a message
  if set -q ANYFFF__CDR_ACTIVITY_PATH
    echo $message >> $ANYFFF__CDR_ACTIVITY_PATH
  end
end

function __cdr_get_dirs -a _dir
  set -l name_hash (__cdr_checksum $_dir)
  set -l dir_hash (__cdr_checksum (ls $_dir))
  set -l target_file (printf "%s/%s.log" $ANYFFF__CDR_CACHE_PATH $name_hash)

  if not __cdr_is_match_checksum $dir_hash $target_file
    __cdr_update_cache $_dir
  end

  cat $target_file | sed 1,2d
end

function __cdr_filter_pwd
  awk -v pwd="$PWD" '$1!=pwd {print}'
end

function __cdr_add_mark -a mark
  sed -e "s/^/$mark /g"
end

function __cdr_checksum -a v
  echo $v | eval $ANYFFF__CHECKSUM_APP | __anyfff_util first
end

function __cdr_is_match_checksum -a dir_hash file_name
  if not test -e $file_name
    return 1
  end

  set -l hash_value (head -n 1 $file_name)
  return ([ $hash_value = $dir_hash ])
end
