import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import CreateAsyncStreamMacros

let testMacros: [String: Macro.Type] = [
  "CreateAsyncStream": CreateAsyncStreamMacro.self
]

final class CreateAsyncStreamTests: XCTestCase {
  func testMacro() {
    assertMacroExpansion(
      """
      @CreateAsyncStream(of: Int, named: "numbers")
      class Example2 {
        init() {
        }
        func something() {
          _numberContinuation.yield(6)
        }
      }
      """,
      expandedSource: """

      class Example2 {
        init() {
        }
        func something() {
          _numberContinuation.yield(6)
        }
        public var numbers: AsyncStream<Int> {
            _numbers
        }
        private let (_numbers, _numbersContinuation) = AsyncStream.makeStream(of: Int.self)
      }
      """,
      macros: testMacros
    )
  }
}
