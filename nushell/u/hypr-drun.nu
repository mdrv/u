use ($nu.default-config-dir + /u/assert-missing.nu)

# v20250102
# Application launcher
export def main [] {
    assert-missing tofi
    ^tofi-drun --fuzzy-match=true --drun-launch=true
}
