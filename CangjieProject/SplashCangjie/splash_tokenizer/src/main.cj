package splash_tokenizer

import splash_lib.*
import std.console.*
import std.collection.*

class TokenizerOutputFormat <: OutputFormat {
    public func makeBuilder(): OutputBuilder {
        TokenizerBuilder()
    }
}

class TokenizerBuilder <: OutputBuilder {
    private var components = ArrayList<String>()

    public func addToken(token: String, tokenType: TokenType): Unit {
        let typeName = tokenType.getString()
        let runes = typeName.toRuneArray()
        var capitalized = ""
        if (runes.size > 0) {
            let first = runes[0]
            if (first >= r'a' && first <= r'z') {
                capitalized = String(Rune(UInt32(first) - 32)) + typeName[1..].toString()
            } else {
                capitalized = typeName
            }
        }
        components.add("${capitalized} token: ${token}")
    }

    public func addToken(token: String, tokenType: ?TokenType): Unit {
        if (let Some(t) <- tokenType) {
            addToken(token, t)
        } else {
            addPlainText(token)
        }
    }

    public func addPlainText(text: String): Unit {
        components.add("Plain text: ${text}")
    }

    public func addWhitespace(whitespace: String): Unit {
        // 忽略空白
    }

    public func build(): String {
        String.join(components.toArray(), delimiter: "\n")
    }
}

main(args: Array<String>): Int64 {
    if (args.size < 1) {
        Console.stdErr.write("Please supply the code to tokenize as a string argument\n")
        return 1
    }

    let code = args[0]
    let highlighter = SyntaxHighlighter(TokenizerOutputFormat(), SwiftGrammar())
    println(highlighter.highlight(code))
    0
}
