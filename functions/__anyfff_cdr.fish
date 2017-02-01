function __anyfff_cdr \
  -a _cdr_subcommand \
  -d 'Returns the merged directory of the directory around the current directory and the history of cd'

  function __anyfff_cdr_main
    begin
      cat (__cdr_history_file_path) \
        | __cdr_filter_pwd \
        | __cdr_add_mark 'cdr_histories_mark' \
        | __anyfff_util reverse
      __cdr_get_dirs (realpath "$PWD/..") \
        | __cdr_filter_pwd \
        | __cdr_add_mark 'cdr_siblings_mark' \
        | __anyfff_util reverse
      __cdr_get_dirs $PWD \
        | __cdr_filter_pwd \
        | __cdr_add_mark 'cdr_branches_mark' \
        | __anyfff_util reverse
      __cdr_root_dirs \
        | __cdr_filter_pwd \
        | __cdr_add_mark 'cdr_root_mark' \
        | __anyfff_util reverse
    end
  end

  function __cdr_history_file_path
    __cdr_path (__anyfff_env cdr_histories_file)
  end

  function __cdr_path -a file_name
    set -l dir (__anyfff_env cdr_cache_path)
    if not test -d $dir
      mkdir -p $dir
    end

    set -l path (string join '/' $dir $file_name)
    touch $path
    echo $path
  end

  function __cdr_clear_cache
    set -l cache_path (__anyfff_env cdr_cache_path)
    set -l history_file (__anyfff_env cdr_histories_file)
    set -l lifetime (__anyfff_env cdr_cache_lifetime)

    find $cache_path -type f \
      -atime "+$lifetime" \
      ! -name $history_file \
      | xargs rm -f ^/dev/null
  end

  function __cdr_append_cd_history
    set -l path (__cdr_history_file_path)
    pwd >> $path
    cat $path \
      | __anyfff_util reverse \
      | __anyfff_util unique \
      | __anyfff_util reverse \
      > $path
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
    set -l target_file (__cdr_path {$name_hash}.log)

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
    set -l path (__anyfff_env activity_path)
    if set -q $path
      echo $message >> $path
    end
  end

  function __cdr_get_dirs -a _dir
    set -l name_hash (__cdr_checksum $_dir)
    set -l dir_hash (__cdr_checksum (ls $_dir))
    set -l target_file (__cdr_path {$name_hash}.log)

    if not __cdr_is_match_checksum $dir_hash $target_file
      __cdr_update_cache $_dir
    end

    cat $target_file | sed 1,2d
  end

  function __cdr_filter_pwd
    awk -v pwd="$PWD" '$1!=pwd {print}'
  end

  function __cdr_add_mark -a _mark
    set -l mark (__anyfff_env $_mark)
    sed -e "s/^/$mark /g"
  end

  function __cdr_checksum -a v
    echo $v | eval (__anyfff_env checksum_app) | __anyfff_util first
  end

  function __cdr_is_match_checksum -a dir_hash file_name
    if not test \( -e $file_name -a -s $file_name \)
      return 1
    end

    set -l hash_value (head -n 1 $file_name)
    return ([ $hash_value -eq $dir_hash ])
  end

  # execute
  switch $_cdr_subcommand
    case append_history
      __cdr_append_cd_history
    case update_cache
      test (count $argv) -gt 1; and set -l target_path $argv[2..-1]
      __cdr_update_cache $target_path
    case clear_cache
      __cdr_clear_cache
    case '*'
      __anyfff_cdr_main
  end
end

# update directory statuses
function __cdr_register --on-variable PWD
  fish -c "__anyfff_cdr append_history" &
  fish -c "__anyfff_cdr update_cache (realpath \"$PWD/..\")" &
  fish -c "__anyfff_cdr update_cache (realpath $PWD)" &
  fish -c "__anyfff_cdr clear_cache" &
end
