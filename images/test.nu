use ../libs *

export def main [context: record = {}] {
    {
        from: 'ghcr.io/fj0r/xy:z'
        user: master
        workdir: /world
        rust: {
            channel: stable
        }
    }
    | merge $context
    | build {|ctx|
        rust prefetch $ctx.user $ctx.workdir 'cargo-fetch' [
            figment
        ]
    }
}
