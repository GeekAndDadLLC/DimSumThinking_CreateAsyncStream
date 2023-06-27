import CreateAsyncStream

@CreateAsyncStream(of: Int, named: "number")
class Example2 {
  init() {
  }
  func something() {
    _numberContinuation.yield(6)
  }
}
