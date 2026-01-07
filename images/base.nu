use ../libs *

export def main [context: record = {}] {
    { from: archlinux }
    | merge $context
    | build {|ctx|

    }
}
