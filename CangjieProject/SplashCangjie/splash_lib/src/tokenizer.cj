package splash_lib

import std.collection.*

class ComponentKind {
    let isToken: Bool
    let isDelimiter: Bool
    let isWhitespace: Bool
    let isNewline: Bool
    init(isToken: Bool, isDelimiter: Bool, isWhitespace: Bool, isNewline: Bool) {
        this.isToken = isToken
        this.isDelimiter = isDelimiter
        this.isWhitespace = isWhitespace
        this.isNewline = isNewline
    }
}

class Component {
    let character: Rune
    let kind: ComponentKind
    init(character: Rune, kind: ComponentKind) {
        this.character = character
        this.kind = kind
    }
}

class Tokenizer {
    func segmentsByTokenizing(code: String, grammar: Grammar): Array<Segment> {
        var segments = ArrayList<Segment>()
        var iter = SegmentIterator(code, grammar)

        var firstOpt = iter.next()
        while (let Some(firstVal) <- firstOpt) {
            let secondOpt = iter.next()
            if (let Some(secondVal) <- secondOpt) {
                var seg = firstVal
                seg.tokens.next = secondVal.tokens.current
                segments.add(seg)
                firstOpt = secondOpt
            } else {
                segments.add(firstVal)
                firstOpt = secondOpt
            }
        }
        segments.toArray()
    }
}

class SegmentIterator {
    private var code: String
    private var grammar: Grammar
    private var runes: Array<Rune>
    private var index: Int64 = -1
    private var tokenCounts = HashMap<String, Int64>()
    private var allTokens = ArrayList<String>()
    private var lineTokens = ArrayList<String>()
    private var currentSegment: ?Segment = None

    init(code: String, grammar: Grammar) {
        this.code = code
        this.grammar = grammar
        this.runes = code.toRuneArray()
    }

    func next(): ?Segment {
        let nextIndex = index + 1

        if (nextIndex >= runes.size) {
            let seg = currentSegment
            currentSegment = None
            return seg
        }

        index = nextIndex
        let ch = runes[nextIndex]
        let comp = makeComponent(ch)

        if (comp.kind.isToken || comp.kind.isDelimiter) {
            if (let Some(seg) <- currentSegment) {
                if (seg.trailingWhitespace == None && comp.kind.isDelimiter == seg.currentTokenIsDelimiter) {
                    if (comp.kind.isDelimiter) {
                        let prevRunes = seg.tokens.current.toRuneArray()
                        let prevChar = prevRunes[prevRunes.size - 1]
                        let shouldMerge = grammar.isDelimiter(prevChar, comp.character)
                        if (!shouldMerge) {
                            return finish(seg, comp, nextIndex)
                        }
                    }
                    var mutableSeg = seg
                    mutableSeg.tokens.current = mutableSeg.tokens.current + String(comp.character)
                    currentSegment = mutableSeg
                    return next()
                } else {
                    return finish(seg, comp, nextIndex)
                }
            } else {
                currentSegment = makeSegment(comp, nextIndex)
                return next()
            }
        } else {
            if (let Some(seg) <- currentSegment) {
                var mutableSeg = seg
                if (let Some(existing) <- mutableSeg.trailingWhitespace) {
                    mutableSeg.trailingWhitespace = existing + String(comp.character)
                } else {
                    mutableSeg.trailingWhitespace = String(comp.character)
                }
                if (comp.kind.isNewline) {
                    mutableSeg.isLastOnLine = true
                }
                currentSegment = mutableSeg
                return next()
            } else {
                var seg = makeSegment(comp, nextIndex)
                seg.trailingWhitespace = String(comp.character)
                seg.isLastOnLine = comp.kind.isNewline
                currentSegment = seg
                return next()
            }
        }
    }

    private func makeComponent(ch: Rune): Component {
        if (ch == r' ' || ch == r'\t' || ch == r'\r') {
            return Component(ch, ComponentKind(false, false, true, false))
        }
        if (ch == r'\n') {
            return Component(ch, ComponentKind(false, false, false, true))
        }
        if (grammar.delimiters.contains(ch)) {
            return Component(ch, ComponentKind(false, true, false, false))
        }
        Component(ch, ComponentKind(true, false, false, false))
    }

    private func makeSegment(comp: Component, idx: Int64): Segment {
        let prevCurrent: ?String = match (currentSegment) {
            case Some(seg) => seg.tokens.current
            case None => None
        }

        var countsCopy = HashMap<String, Int64>()
        for ((k, v) in tokenCounts) {
            countsCopy[k] = v
        }
        var lineTokensCopy = ArrayList<String>()
        for (t in lineTokens) {
            lineTokensCopy.add(t)
        }

        var seg = Segment()
        seg.prefix = String(runes[0..idx])
        seg.tokens = Tokens()
        seg.tokens.all = allTokens.toArray()
        seg.tokens.counts = countsCopy
        seg.tokens.onSameLine = lineTokensCopy.toArray()
        seg.tokens.previous = prevCurrent
        seg.tokens.current = String(comp.character)
        seg.tokens.next = None
        seg.trailingWhitespace = None
        seg.currentTokenIsDelimiter = comp.kind.isDelimiter
        seg.isLastOnLine = false
        seg
    }

    private func finish(segment: Segment, comp: Component, idx: Int64): Segment {
        var count = tokenCounts.get(segment.tokens.current) ?? 0
        count += 1
        tokenCounts[segment.tokens.current] = count
        allTokens.add(segment.tokens.current)
        if (segment.isLastOnLine) {
            lineTokens = ArrayList<String>()
        } else {
            lineTokens.add(segment.tokens.current)
        }
        currentSegment = makeSegment(comp, idx)
        return segment
    }
}
