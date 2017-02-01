function __anyfff_env
  # setup
  functions -q __anyfff_env_setup; and __anyfff_env_setup

  for name in $argv
    eval "echo \$anyfff_$name"
  end
end

function __anyfff_env_register_variable -a name value
  set -g anyfff_{$name} $value
end

function __anyfff_env_try -a x_value default_value
  if test -n $x_value
    echo $x_value
  else
    echo $default_value
  end
end

function __anyfff_env_register_event -a v_name x_name
  eval (printf \
    "function __anyfff_%s_change_event --on-variable %s; \
      __anyfff_env_register_variable %s \$%s; \
     end" $v_name $x_name $v_name $x_name)
end

function __anyfff_env_setup
  # finder application
  if set -xq ANYFFF__FINDER_APP
    set -l finders sk peco fzf
    for finder in $finders
      if test -x $finder
        __anyfff_env_register_variable finder $finder
        break
      end
    end
  else
    __anyfff_env_register_variable finder $ANYFFF__FINDER_APP
  end
  __anyfff_env_register_event finder ANYFFF__FINDER_APP

  # If you are using a multi-selectable finder, set this env.
  __anyfff_env_register_variable finder_option_multi (__anyfff_env_try $ANYFFF__FINDER_APP_OPTION_MULTI '')
  __anyfff_env_register_event finder_option_multi ANYFFF__FINDER_APP_OPTION_MULTI

  # cache path for history of change directory
  __anyfff_env_register_variable cdr_cache_path (__anyfff_env_try $ANYFFF__CDR_CACHE_PATH ~/.local/share/fish/anyfff/cdr)
  __anyfff_env_register_event cdr_cache_path ANYFFF__CDR_CACHE_PATH

  # 3days
  __anyfff_env_register_variable cdr_cache_lifetime (__anyfff_env_try $ANYFFF__CDR_CACHE_LIFETIME 3)
  __anyfff_env_register_event cdr_cache_lifetime ANYFFF__CDR_CACHE_LIFETIME

  # chucksum command
  if test -x sha256sum
    __anyfff_env_register_variable checksum_app 'sha256sum'
  else
    __anyfff_env_register_variable checksum_app 'shasum -a 256'
  end

  # cache file for cd history
  __anyfff_env_register_variable cdr_histories_file history.log

  # When this environment variable is enabled,
  # cd history reference and generation log will be outputted
  # example: set -x ANYFFF__CDR_ACTIVITY_LOG_PATH /tmp/anyfff_cdr_activities.log
  __anyfff_env_register_variable cdr_activity_log_path (__anyfff_env_try $ANYFFF__CDR_ACTIVITY_LOG_PATH '')
  __anyfff_env_register_event cdr_activity_log_path ANYFFF__CDR_ACTIVITY_LOG_PATH

  # marks
  __anyfff_env_register_variable cdr_histories_mark '-'
  __anyfff_env_register_variable cdr_siblings_mark ':'
  __anyfff_env_register_variable cdr_branches_mark '>'
  __anyfff_env_register_variable cdr_root_mark '<'

  # context file search configuration
  __anyfff_env_register_variable file_search_maxdepth (__anyfff_env_try $ANYFFF__FILE_SEARCH_MAXDEPTH 2)
  __anyfff_env_register_event file_search_maxdepth ANYFFF__FILE_SEARCH_MAXDEPTH

  # destroy self
  functions -e __anyfff_env_setup
end
