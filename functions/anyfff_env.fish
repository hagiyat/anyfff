function __anyfff_env --on-event anyfff_set_envs
  # finder application
  set -l ANYFFF__FINDER_COLLECTION sk peco fzf percol
  if not set -q ANYFFF__FINDER_APP
    for f in $ANYFFF__FINDER_COLLECTION
      if test -x $f
        set -x $ANYFFF__FINDER_APP $f
        break
      end
    end
  end

  # If you are using a multi-selectable finder, set this env.
  set -q ANYFFF__FINDER_APP_OPTION_MULTIPLE; \
    and set -x ANYFFF__FINDER_APP_OPTION_MULTIPLE ''

  # cdr configuration
  set -x ANYFFF__CDR_CACHE_PATH ~/.local/share/fish/cdr
  if not test -d $ANYFFF__CDR_CACHE_PATH
    mkdir -p $ANYFFF__CDR_CACHE_PATH
  end

  # 3days
  set -x ANYFFF__CDR_CACHE_LIFETIME 3

  # chucksum command
  if test -x sha256sum
    set -x ANYFFF__CHECKSUM_APP 'sha256sum'
  else
    set -x ANYFFF__CHECKSUM_APP 'shasum -a 256'
  end

  # cache file for cd history
  set -x ANYFFF__CDR_HISTORIES_FILE history.log
  set -x ANYFFF__CDR_HISTORIES_PATH "$ANYFFF__CDR_CACHE_PATH/$ANYFFF__CDR_HISTORIES_FILE"
  touch $ANYFFF__CDR_HISTORIES_PATH

  # When this environment variable is enabled,
  # cd history reference and generation log will be outputted
  # set -x ANYFFF__CDR_ACTIVITY_PATH "$ANYFFF__CDR_CACHE_PATH/activity.log"
  if set -q ANYFFF__CDR_ACTIVITY_PATH
    touch $ANYFFF__CDR_ACTIVITY_PATH
  end

  # marks
  set -x ANYFFF__CDR_HISTORIES_MARK '-'
  set -x ANYFFF__CDR_SIBLINGS_MARK ':'
  set -x ANYFFF__CDR_BRANCHES_MARK '>'
  set -x ANYFFF__CDR_ROOT_MARK '<'

  # context file search configuration
  if not set -q ANYFFF__FILESEARCH_MAXDEPTH
    set -x ANYFFF__FILESEARCH_MAXDEPTH 2
  end

  # flag value
  set -x ANYFFF__ENVIRONMENTS 1
end
