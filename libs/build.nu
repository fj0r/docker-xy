use lg.nu

export def main [acts] {
    let ctx = $in
    let working_container = buildah from $ctx.from
    let mountpoint = buildah mount $working_container
    buildah config --author $ctx.username $working_container

    do $acts $ctx

    let image = ($ctx.image):($ctx.tags)
    buildah commit $working_container $image
    lg push $image
    buildah push --creds ($ctx.username):($ctx.password) $image
}
