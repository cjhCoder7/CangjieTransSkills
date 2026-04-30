package splash_html_gen

import splash_lib.*
import std.console.*

main(args: Array<String>): Int64 {
    if (args.size < 1) {
        Console.stdErr.write("Please supply the code to generate HTML for as a string argument\n")
        return 1
    }

    let code = args[0]
    let highlighter = SyntaxHighlighter(HTMLOutputFormat(), SwiftGrammar())
    println(highlighter.highlight(code))
    0
}
