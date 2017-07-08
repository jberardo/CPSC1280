BEGIN {
  FS="  "
}
{
  print "<row>"
  print "<entry>"$0"</entry>"
  print "</row>"
}
END {
}
