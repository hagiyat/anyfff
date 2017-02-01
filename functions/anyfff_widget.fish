function anyfff_widget -a subcommand
  test (count $argv) -gt 1; and set -l subcommand_arguments $argv[2..-1]

  function put_history \
    --inherit-variable subcommand_arguments \
    -d 'Put the command selected from the command history on the commandline'
    history \
      | __anyfff_util reverse \
      | __anyfff_util unique \
      | __anyfff_util reverse \
      | __anyfff_finder -s "history > " \
      | read -l selected
    if [ $selected ]
      commandline $selected
    end
    commandline -f repaint
  end

  function put_filename \
    --inherit-variable subcommand_arguments \
    -d 'Put the filename selected from some files on the commandline'
    __anyfff_context_file_search \
      | __anyfff_finder -m "file > " \
      | read -l selected
    if [ $selected ]
      commandline -i $selected
      commandline -f repaint
    end
  end

  function checkout_git_branch \
    --inherit-variable subcommand_arguments \
    -d 'Checkout to branch selected from branch including remote branch'
    if git_is_repo
      begin \
        git branch; \
        git branch -r | sed 1,2d | sed 's/^ *origin\//- /g'; \
      end \
      | __anyfff_finder -s "checkout > " \
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

  function put_git_branch \
    --inherit-variable subcommand_arguments \
    -d 'Put the selected branch on the commandline'
    if git_is_repo
      git branch \
        | __anyfff_finder -s "branch > " \
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

  function kill_process \
    --inherit-variable subcommand_arguments \
    -d 'Kill 9 for the selected running process'
    ps -u $USER -o pid,stat,%cpu,%mem,cputime,command \
      | sed 1,2d \
      | __anyfff_finder -s "kill > " \
      | awk '{print $1}' \
      | read -l selected
    if [ $selected ]
      commandline "kill -9 $selected"
    end
  end

  function cdr \
    --inherit-variable subcommand_arguments \
    -d 'Select from cd history and directories around the current directory and cd to that directory'
    if test (count $subcommand_arguments) -gt 0
      builtin cd $subcommand_arguments
    else
      __anyfff_cdr main \
        | __anyfff_finder -s "cd:$PWD > " \
        | __anyfff_util last \
        | read -l selected
      if [ $selected ]
        builtin cd $selected
      end
    end
  end

  # call subcommand
  if contains $subcommand \
    'put_history' 'put_filename' 'checkout_git_branch' 'put_git_branch' 'kill_process' 'cdr'
    eval $subcommand
  else
    echo "Undefined subcommand / $subcommand"
  end
end
