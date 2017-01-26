function __anyfff_util -a subcommand
  switch $subcommand
    case reverse
      awk '{a[i++]=$0} END {for (j=i-1; j>=0;) print a[j--]}'
    case unique
      awk '!colname[$1]++ {print}'
    case first
      awk '{print $NR}'
    case last
      awk '{print $NF}'
    case '*'
      echo "undefined subcommand / $subcommand"
      return 1
  end
end
