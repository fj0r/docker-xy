use lg.nu

export def main [acts --squash] {
    let ctx = $in
    let working_container = buildah from $ctx.from
    let mountpoint = buildah mount $working_container
    buildah config --author $ctx.author $working_container

    {
        BUILDAH_WORKING_CONTAINER: $working_container
        BUILDAH_WORKING_MOUNTPOINT: $mountpoint
    }
    | load-env
    do $acts $ctx

    let image = ($ctx.image):($ctx.tags)
    if $squash {
        buildah commit --squash $working_container $image
    } else {
        buildah commit $working_container $image
    }
    lg o push $image
    buildah push --creds ($ctx.author):($ctx.password) $image
}
