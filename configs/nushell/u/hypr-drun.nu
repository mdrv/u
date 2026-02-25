use ($nu.default-config-dir + /u/assert-missing.nu)

# v20250225 - Auto-close after 10 seconds for touch use
# Application launcher
export def main [] {
    assert-missing tofi
    # Run tofi with 10 second timeout - auto-closes if no selection made
    ^timeout --foreground 10s tofi-drun --fuzzy-match=true --drun-launch=true
}
