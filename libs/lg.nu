export def main [...msg: any] {
    let now = date now | format date '%FT%T.%3f'
    print $"(ansi grey)($now)│($msg | str join ' ')(ansi reset)"
}
