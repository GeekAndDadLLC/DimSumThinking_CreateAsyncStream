import CreateAsyncStream

@CreateAsyncStream(of: Int.self, named: "number")
class Example2 {
  init() {
  }
  func something() {
    _numberContinuation.yield(6)
  }
  
  public var test: AsyncStream<Int> {
    _test
  }
  
  private let (_test, _testContinuation) = AsyncStream.makeStream(of: Int.self)
}
