# dependencies
fundle plugin 'fisherman/git_util'

# environments {{{
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
# }}}

# widgets
function anyfff.widget.put_history -d 'Put the command selected from the command history on the commandline'
  builtin history \
    | anyfff.util.reverse \
    | anyfff.util.unique \
    | anyfff.util.reverse \
    | anyfff.finder.single "history > " \
    | read -l selected
  if [ $selected ]
    commandline $selected
  end
  commandline -f repaint
end

function anyfff.widget.put_filename -d 'Put the filename selected from some files on the commandline'
  anyfff.context_file_search \
    | anyfff.finder.multiple "file > " \
    | read -l selected
  if [ $selected ]
    commandline -i $selected
    commandline -f repaint
  end
end

function anyfff.widget.checkout_git_branch -d 'Checkout to branch selected from branch including remote branch'
  if git_is_repo
    begin \
      git branch; \
      git branch -r | sed 1,2d | sed 's/^ *origin\//- /g'; \
    end \
    | anyfff.finder.single "checkout > " \
    | read -l selected

    if [ $selected ]
      set -l mark (echo $selected >| string sub -l 2 >| string trim)
      set -l branch (echo $selected >| string sub -s 2 >| string trim)
      switch $mark
        case '-'
          commandline "git checkout -b $branch"
        case ''
          commandline "git checkout $branch"
      end
    end
    commandline -f repaint
  else
    echo '.git?'
  end
end

function anyfff.widget.put_git_branch -d 'Put the selected branch on the commandline'
  if git_is_repo
    git branch \
      | anyfff.finder.single "branch > " \
      | awk '{print $NF}' \
      | read -l selected
    if [ $selected ]
      commandline -i $selected
      commandline -f repaint
    end
  else
    echo '.git?'
  end
end

function anyfff.widget.kill_process -d 'Kill 9 for the selected running process'
  ps -u $USER -o pid,stat,%cpu,%mem,cputime,command \
    | sed 1,2d \
    | anyfff.finder.single "kill > " \
    | awk '{print $1}' \
    | read -l selected
  if [ $selected ]
    commandline "kill -9 $selected"
  end
end

function anyfff.widget.cdr -d 'Select from cd history and directories around the current directory and cd to that directory'
  # set -q argv[1]; and set -l a $argv[1]
  if test (count $argv) -gt 0
    builtin cd $argv
  else
    anyfff.cdr \
      | anyfff.finder.single "cd:$PWD > " \
      | anyfff.util.last \
      | read -l selected
    if [ $selected ]
      builtin cd $selected
    end
  end
end
