#thee becomes you
#thou becomes you
#thine becomes your
#thy becomes your
#art becomes are
#shall becomes will
#wilt becomes will
#ere becomes before
#doth becomes does

BEGIN {
  FS="[a-zA-Z]+ "
  FILE_OUT="fixed.txt"

  rm -r FILE_OUT
}
{
  for (i=1; i<=NF; i++)
  {
    word = tolower($i)

    if (word ~ "thee") { $i="you" wordCount["thee"]++ }
    if (word ~ "thou") { $i="you" wordCount["thou"]++ }
    if (word ~ "thine") { $i="your" wordCount["thine"]++ }
    if (word ~ "thy") { $i="your" wordCount["thy"]++ }
    if (word ~ "art") { $i="are" wordCount["art"]++ }
    if (word ~ "shall") { $i="will" wordCount["shall"]++ }
    if (word ~ "wilt") { $i="will" wordCount["wilt"]++ }
    if (word ~ "ere") { $i="before" wordCount["ere"]++ }
    if (word ~ "doth") { $i="does" wordCount["doth"]++ }
  }
}
END {
  for (i in wordCount)
    printf "%s was replaced %d times.\n", i,  wordCount[i]
}
