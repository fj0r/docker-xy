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
ls ($basedir | path join "*.nu") | where name != $env.CURRENT_FILE | each { |file|
    print $"(now) source ($file.name)"
    with-env $env {
        ^nu $file.name
    }
}

if ($env.POSTBOOT? | is-not-empty) {
    print $"(now) postboot ($env.POSTBOOT)"
    nu -c $"source ($env.POSTBOOT)"
}

print $"(now) boot completed"

let arg = ($env.args? | default [] | get 0?)

if ($arg == null) {
    print "entering interactive mode..."
    exec nu
} else if ($arg == "srv") {
    print "entering service mode, monitoring process status."
    try {
        pueue wait --group default
    } catch {
        print "error: service exited unexpectedly"
    }
    pueue kill
    exit 1
} else {
    print $"entering batch mode: ($env.args)"
    let cmd = ($env.args | get 0)
    let rest = ($env.args | drop nth 0)
    run-external $cmd ...$rest
}
