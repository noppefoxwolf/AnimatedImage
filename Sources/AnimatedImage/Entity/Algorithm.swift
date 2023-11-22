
extension Sequence {
    /// A sequence of the partial results that `reduce` would employ.
    func scan<Result>(
        _ initialResult: Result,
        _ nextPartialResult: @escaping (Result, Element) -> Result
    ) -> AnySequence<Result> {
        var iterator = makeIterator()
        return .init(
            sequence(first: initialResult) { partialResult in
                iterator.next().map {
                    nextPartialResult(partialResult, $0)
                }
            }
        )
    }
}

extension Sequence where Element: AdditiveArithmetic & ExpressibleByIntegerLiteral {
    var runningSum: AnySequence<Element> { scan(0, +).dropFirst() }
}
