#!/bin/bash

# grep
# searches for pattern in one or more filename(s) (or stdin if no filename is specified)
# $ grep options pattern filename(s)

# display lines containing the string sales
grep "sales" emp.lst

who | grep jab  > foo

# used with multiple filenames, displays filenames in output
grep "director" emp1.lst emp2.lst

# Quoting is essential if the search string consists of more than one word or metacharacters
# it’s always safe to quote the pattern
grep gordon lightfoot emp.lst # error
grep 'gordon lightfoot' emp.lst # right way

# Recall that double quotes protect single quotes
grep ‘neil o’bryan’ emp.lst # error
grep "neil o’bryan" emp.lst # even better way (always use double quotes!)
# always use double quotes
# especially if the special characters in the pattern require command substitution or variable evaluation to be performed

# Options
# -i Ignores case for matching
grep -i ‘WILCOX’ emp.lst
# -v Doesn’t display lines matching expression ("delete" lines from output)
grep -v ‘director’ emp.lst > otherlist
wc -l otherlist
# -n Displays line numbers along with lines
# -c Displays count of number of occurrences
# -l Displays list of filenames only (ex: locate files where a variable or system call has been used in source code)
# -e <exp> Specifies expression exp with this option. Can use multiple times. Also used for matching expression beginning with a hyphen.
grep -e woodhouse -e wood -e woodcock emp.lst
grep -e "-mtime" /var/spool/cron/crontabs/*
# -x Matches pattern with entire line (doesn’t match embedded patterns)
# -f file Takes patterns from file, one per line
# -E Treats pattern as an extended regular expression (ERE)
# -F Matches multiple fixed strings (in fgrep-style)
# -n Displays line and n lines above and below (Linux only)
grep -1 “foreach” count.pl # One line above and below
# -A n Displays line and n lines after matching lines (Linux only)
# -B n Displays line and n lines before matching lines (Linux only)
find $HOME -name “*.c” -exec grep -l “#include <fcntl.h>” {} \; > foo

Basic Regular Expressions (BRE)
Expression is a feature of the command that uses it and has nothing to do with the shell
Some of the characters used by regular expressions are also meaningful to the shell—enough reason why these expressions should be quoted

Two categories: basic (BRE) and extended (ERE)
grep uses (RE by default and ERE with the -E option
sed supports only the BRE set

Regular expressions are interpreted by the command and not by the shell.
Quoting ensures that the shell isn’t able to interfere and interpret the metacharacters in its own way.

The Character Class
Group of characters enclosed within a pair of rectangular brackets, [ ]
Match is performed for any single character in the group
Example: [od] -> Either o or d

Basic Regular Expression (BRE)
Character Set Used by grep, sed, and awk
Pattern     Matches
*           Zero or more occurrences of the previous character
.           A single character
[pqr]       A single character p, q, or r
[c1-c2]     A single character within the ASCII range represented by c1 and c2
[^pqr]      A single character which is not a p, q, or r
^pat        Pattern pat at beginning of line
pat$        Pattern pat at end of line

Examples:
g*          Nothing or g, gg, ggg, etc.
gg*         g, gg, ggg, etc.
.*          Nothing or any number of characters
[1-3]       A digit between 1 and 3
[^a-zA-Z]   A nonalphabetic character
bash$       bash at end of line
^bash$      bash as the only word in line
^$          Lines containing nothing

Regular expression required to match woodhouse and wodehouse should be this:
wo[od][de]house
$ grep “wo[od][de]house” emp.lst

Negating a Class
Regular expressions use the ^ (caret) to negate the character class, while the shell uses the ! (bang)
So, [^a-zA-Z] matches a single nonalphabetic character string
As with wild cards, the character class is the only way you can negate a single character. For instance, [^p] represents any character other than p

The * (asterisk) refers to the immediately preceding character
Its interpretation is the trickiest because it has absolutely no resemblance with the * used by wild cards or DOS, etc.
It indicates that the previous character can occur many times, or not at all

Example: e* matches the single character e or any number of es
Because the previous character may not occur at all, it also matches a null string
It also mathces the following strings: e ee eee eeee .....
Do not use e* to match a string beginning with e*, use ee* instead

s*printf matches sprintf, ssprintf, sssprintf, and so forth, but it also matches printf
because the previous character, s, which the * refers to, may not occur at all

If the * is the first character in a regular expression, then it’s treated literally (i.e., matches itself)

Match trueman and truman
grep "true*man" emp.lst

Match wilcocks and wilcox
grep "wilco[cx]k*s*" emp.lst

The Dot
Matches a single character
The shell uses the ? character to indicate that
2... -> matches a four-character pattern beginning with a 2 (2??? in shell)
.* -> signifies any number of characters, or none, very useful regular expression

The *
Look for p. woodhouse but not sure whether it actually exists in the file as p.j. woodhouse
$ grep "p.*woodhouse" emp.lst

The . and * lose their meanings when placed inside the character class
The * is also matched literally if it’s the first character of the expression (grep “*” looks for an asterisk)


To literally look for the name p.j. woodhouse: p\.j\. woodhouse
Escaped with \, the same character used in the shell for despecializing the next character

Specifying Pattern Locations (^ and $)
^ — Matches pattern at the beginning of a line
$ — Matches pattern at the end of a line

Caret (^) has a triple role in regular expressions:
 - beginning of a character class (e.g., [^a-z]), it negates every character of the class
 - outside it, and at the beginning of the expression (e.g., ^2...), the pattern is matched at the beginning of the line
 - any other location (e.g., a^b), it matches itself literally

Extended Regular Expressions (ERE)
Make it possible to match dissimilar patterns with a single expression
POSIX-compliant versions of grep use them with the -E option
ERE set includes two special characters, + and ?

The + and ?
+ — Matches one or more occurrences of the previous character
? — Matches zero or one occurrence of the previous character

b+ matches b, bb, bbb, etc., but, unlike b*, it doesn’t match nothing
b? matches either a single instance of b or nothing
These characters restrict the scope of match as compared to the *
$ grep -E “true?man” emp.lst

Example: "#include +<stdio.h>" to match the following patterns:
 - #include <stdio.h>
 - #include  <stdio.h>
 - #include   <stdio.h>
 - #include    <stdio.h>
 - etc.

If not sure if there’s a space between # and include, include the ?
 - # ?include +<stdio.h>

Regular Expression (ERE) Set Used by grep, egrep and awk
Expression        Significance
ch+               Matches one or more occurrences of character ch
ch?               Matches zero or one occurrence of character ch
exp1|exp2         Matches exp1 or exp2
(x1|x2)x3         Matches x1x3 or x2x3

Examples:
g+                Matches at least one g
g?                Matches nothing or one g
GIF|JPEG          Matches GIF or JPEG
(lock|ver)wood    Matches lockwood or verwood

The | and ()
$ grep -E 'wilco[cx]k*s*|wood(house|cock)' emp.lst



The Stream Editor (sed)
sed performs noninteractive operations on a data stream
sed uses instructions to act on text
An instruction combines an address for selecting lines, with an action to be taken on them
Syntax: sed options 'address action' file(s)

Addressing in sed is done in two ways
 - By one or two line numbers (like 3,7)
 - By specifying a /-enclosed pattern which occurs in a line (like /From:/)

sed processes several instructions in a sequential manner
Each instruction operates on the output of the previous instruction

Common options
-e option that lets you use multiple instructions
-f option to take instructions from a file

Internal Commands Used by sed
Command           Description
i,a,c             Inserts, appends, and changes text
d                 Deletes line(s)
p                 Prints line(s) on standard output
q                 Quits after reading up to addressed line
r flname          Places contents of file flname after line
w flname          Writes addressed lines to file flname
=                 Prints line number addressed
s/s1/s2/          Replaces first occurrence of expression s1 in all lines with expression s2
s/s1/s2/g         As above but replaces all occurrences

Examples:
1,4d              Deletes lines 1 to 4
10q               Quits after reading the first 10 lines
3,$p              Prints lines 3 to end (-n option required)
$!p               Prints all lines except last line (-n option required)
/begin/,/end/p    Prints line containing begin through line containing end (-n option required)
10,20s/-/:/       Replaces first occurrence of - in lines 10 to 20 with a :
s/echo/printf/g   Replaces all occurrences of echo in all lines with printf

Components of a sed Instruction
sed '1,$ s/^bold/BOLD/g' foo
1,s -> address
s/^bold/BOLD/g -> action

