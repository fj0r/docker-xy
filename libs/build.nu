use lg.nu

export def main [acts --squash] {
    let ctx = $in
    let working_container = buildah from $ctx.from
    let mountpoint = buildah mount $working_container
    buildah config --author $ctx.author $working_container

    do $acts {
        ...$ctx
        working_container: $working_container
        mountpoint: $mountpoint
    } {
        copy: {|src, dst|
            lg o copy $src $dst
            buildah copy $working_container $src $dst
        }
        run: {|cmd: list|
            $cmd
            | str join ' && '
            | lg f run
            | buildah run $working_container bash -c $in
        }
        conf: {
            env: {|rec: record|
                $rec
                | lg f config env
                | items {|k, v| [--env ($k)=($v)] }
                | flatten
                | buildah config ...$in $working_container
            }
            expose: {|...vec: list|
                $vec
                | lg f config expose
                | each {|x|
                    let x = $x | into string
                    if ($x | str starts-with u) {
                        [--port ($x | str substring 1..)/udp]
                    } else {
                        [--port ($x)/tcp]
                    }
                }
                | flatten
                | buildah config ...$in $working_container
            }
            volume: {|...vec: list|
                $vec
                | lg f config volume
                | each {|x| [--volume $x] }
                | flatten
                | buildah config ...$in $working_container
            }
            workdir: {|...vec: list|
                $vec
                | lg f config workdir
                | each {|x| [--workingdir $x] }
                | flatten
                | buildah config ...$in $working_container
            }
            entrypoint: {|...vec: list|
                $vec
                | lg f config entrypoint
                | to json -r
                | buildah config --entrypoint $in $working_container
            }
            cmd: {|...vec: list|
                $vec
                | lg f config cmd
                | to json -r
                | buildah config --cmd $in $working_container
            }
        }
    }

    let image = ($ctx.image):($ctx.tags)
    if $squash {
        buildah commit --squash $working_container $image
    } else {
        buildah commit $working_container $image
    }
    lg o push $image
    buildah push --creds ($ctx.author):($ctx.password) $image
}
