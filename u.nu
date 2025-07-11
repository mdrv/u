#!nu

const TOOL_DIRS = {
    nvim: "nvim/lua"
}

export def main [] {
    print "Hello, world!"
}

export def init [
    ...tools: string
] {
    for $tool in $tools {
        print ($TOOL_DIRS | get -i $tool)
    }
}
