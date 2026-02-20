export def main []: any -> string {
    if ($in | describe -n) =~ "^(list|table|record)" {
        $"($in | table -e)"
    } else {
        $"($in)"
    }
}
