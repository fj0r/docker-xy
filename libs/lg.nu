export def o [...msg: any] {
    let now = date now | format date '%FT%T.%3f'
    print $"(ansi grey)($now)│($msg | str join ' ')(ansi reset)"
}

export def f [...prefix] {
    let n = $in
    o ($prefix | str join '-') $n
    $n
}
