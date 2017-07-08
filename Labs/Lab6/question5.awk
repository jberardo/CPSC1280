BEGIN {
  FS=" "
  printf "%-30s%-10s\n", "Name", "Size"
}
{
  printf "%-30s%-0.2f k\n", $9, $5/1024
  total += $5
  count++
  if ($5 > largest)
    largest = $5
}
END {
  avg = total / count
  printf "Total: %.2f k\tAverage: %.2f k\tLargest: %.2f k\n", total/1024, avg/1024, largest/1024
}
