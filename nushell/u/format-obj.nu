export def main []: nothing -> string {
    if ($in | describe -n) =~ "^(list|table|record)" {
        $"($in | table -e)"
    } else {
        $"($in)"
    }
}
