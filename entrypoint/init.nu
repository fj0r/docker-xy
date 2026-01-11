#!/usr/bin/env nu

def now [] {
    $"[(date now | format date '%Y-%m-%dT%H:%M:%S')]"
}

if ($env.DEBUG? == 'true') { $env.config.show_errors = true }

if ($env.PREBOOT? | is-not-empty) {
    print $"(now) preboot ($env.PREBOOT)"
    nu -c $"source ($env.PREBOOT)"
}

if (which pueued | is-empty) { error make {msg: "pueue not found, please install it."} }
pueued -d

let basedir = ($env.CURRENT_FILE | path dirname)
ls ($basedir | path join "*.nu" | into glob)
| where name != $env.CURRENT_FILE
| each { |file|
    print $"(now) source ($file.name)"
    ^nu $file.name
}

if ($env.POSTBOOT? | is-not-empty) {
    print $"(now) postboot ($env.POSTBOOT)"
    nu -c $"source ($env.POSTBOOT)"
}

print $"(now) boot completed"

export def main [...args] {
    if ($args | is-empty) {
        print "entering interactive mode..."
        exec nu
    } else if ($args.0 == "srv") {
        print "entering service mode, monitoring process status."
        try {
            pueue wait --group default
        } catch {
            print "error: service exited unexpectedly"
        }
        pueue kill
        exit 1
    } else {
        print $"entering batch mode: ($args)"
        let cmd = ($args | get 0)
        let rest = ($args | drop nth 0)
        run-external $cmd ...$rest
    }
}
