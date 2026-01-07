use ../libs *

export def main [context: record = {}] {
    {
        from: archlinux
        author: unnamed
        timezone: Asia/Shanghai
        user: master
        workdir: /world
        config: {
            nushell: 'https://github.com/fj0r/nushell.git'
        }
    }
    | merge $context
    | build {|ctx, vt|
        do $vt.conf.expose 22
        do $vt.conf.env {
            LANG: C.UTF-8
            LC_ALL: C.UTF-8
            TIMEZONE: $ctx.timezone
            PYTHONUNBUFFERED: x
        }
        do $vt.conf.volume $ctx.workdir
        do $vt.conf.workdir $ctx.workdir
        $vt | arch update
        $vt | arch install [
            sudo cronie tzdata
            # base-devel
            nushell git
            openssh rsync dropbear s3fs
            tcpdump socat websocat
            ripgrep dust
        ]
        $vt | arch config timezone $ctx.timezone
        $vt | arch config sudo
        $vt | arch config git $ctx.author
        let xdg_home = $vt | arch config master $ctx.user $ctx.workdir
        $vt | arch config nushell $ctx.user $xdg_home $ctx.config.nushell
        $vt | arch setup python [
            ty
            httpx aiofile aiostream fastapi uvicorn
            debugpy pytest pydantic pydantic-graph PyParsing
            typer pydantic-settings pyyaml
            boltons decorator
        ]
        $vt | arch setup js [
            @typespec/compiler @typespec/json-schema
            vscode-langservers-extracted
            yaml-language-server
        ]
        do $vt.copy entrypoint /entrypoint
        do $vt.conf.env {
            DEBUGE: ''
            PREBOOT: ''
            POSTBOOT: ''
            CRONFILE: ''
            git_pull: ''
        }
    }
}
