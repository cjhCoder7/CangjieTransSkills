package splash_markdown

import splash_lib.*
import std.console.*
import std.fs.*
import std.io.*

main(args: Array<String>): Int64 {
    if (args.size < 1) {
        Console.stdErr.write("Please supply the path to a Markdown file to process as an argument\n")
        return 1
    }

    let path = Path(args[0])
    try {
        var file = File(path, Read)
        let allBytes = readToEnd(file)
        file.close()
        let content = String.fromUtf8(allBytes)
        let decorator = MarkdownDecorator()
        println(decorator.decorate(content))
        0
    } catch (e: Exception) {
        Console.stdErr.write("Failed to open Markdown file at '${args[0]}': ${e.message}\n")
        1
    }
}
