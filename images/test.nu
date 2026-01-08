use ../libs *

export def main [context: record = {}] {
    {
        from: 'ghcr.io/fj0r/xy:z'
        author: fj0r
        user: master
        workdir: /world
        rust: {
            channel: stable
        }
        image: test
    }
    | merge $context
    | build --skip-push {|ctx|
        rust prefetch --debug --test $ctx.user $ctx.workdir 'buildah-test' [
        ]
    }
}
