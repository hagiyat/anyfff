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
