# Compile C++ file(s) - either passed as arguments or selected via input list
export def main [...filepaths: string] {
    let files = if ($filepaths | is-empty) {
        let cpp_files = (glob "**/*.cpp" | path basename)
        
        if ($cpp_files | is-empty) {
            print "No C++ files found in the current directory"
            return
        }
        
        let selected = ($cpp_files | input list "Select a C++ file to compile:")
        
        if ($selected | is-empty) {
            print "No file selected"
            return
        }
        
        [$selected]
    } else {
        $filepaths
    }
    
    for file in $files {
        let output = ($file | path parse | get stem)
        
        print $"Compiling ($file)..."
        g++ $file -o $output
        print $"Compiled successfully: ($output)"
    }
}
