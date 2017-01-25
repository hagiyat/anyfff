function anyfff.util.reverse
  awk '{a[i++]=$0} END {for (j=i-1; j>=0;) print a[j--]}'
end

function anyfff.util.unique
  awk '!colname[$1]++ {print}'
end

function anyfff.util.last
  awk '{print $NF}'
end

function anyfff.util.first
  awk '{print $NR}'
end
