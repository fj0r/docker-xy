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
    | build {|ctx|
        conf expose 22
        conf env {
            LANG: C.UTF-8
            LC_ALL: C.UTF-8
            TIMEZONE: $ctx.timezone
            PYTHONUNBUFFERED: x
        }
        conf volume $ctx.workdir
        conf workdir $ctx.workdir
        arch update
        arch install [
            sudo cronie tzdata
            # base-devel
            nushell git
            openssh rsync dropbear s3fs
            tcpdump socat websocat
            ripgrep dust
        ]
        arch config timezone $ctx.timezone
        arch config sudo
        arch config git $ctx.author
        let xdg_home = arch config master $ctx.user $ctx.workdir
        arch config nushell $ctx.user $xdg_home $ctx.config.nushell
        arch setup python [
            ty
            httpx aiofile aiostream fastapi uvicorn
            debugpy pytest pydantic pydantic-graph PyParsing
            typer pydantic-settings pyyaml
            boltons decorator
        ]
        arch setup js [
            @typespec/compiler @typespec/json-schema
            vscode-langservers-extracted
            yaml-language-server
        ]
        copy entrypoint /entrypoint
        conf env {
            DEBUGE: ''
            PREBOOT: ''
            POSTBOOT: ''
            CRONFILE: ''
            git_pull: ''
        }
        conf entrypoint "/entrypoint/init.sh"
    }
}
