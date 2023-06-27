import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics
import Foundation


/// This macro adds a public async stream of a given type and a private continuation
///  to a class
///
///     `@CreateAsyncStream(of: Int, named: "numbers")`
///
/// adds the following members to the class:
/// `public var numbers: AsyncStream<Int> { _numbers }
/// `private let (_numbers, _numbersContinuation)`
/// `   = AsyncStream.makeStream(of: Int.self)`
///
///
public struct CreateAsyncStreamMacro: MemberMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {

    guard declaration.as(ClassDeclSyntax.self) != nil
            // FIXME:  ??? Structs also?
            // || declaration.as(StructDeclSyntax.self) != nil
    else {
      throw CustomError.message("@CreateAsyncStream only works on classes")
    }
    
    guard case .argumentList(let arguments) = node.argument,
          arguments.count == 2,
          let memberAccessExpr = arguments.first?.expression.as(MemberAccessExprSyntax.self),
          let rawType = memberAccessExpr.base?.as(IdentifierExprSyntax.self)
    else {
      throw CustomError.message(#"@CreateAsyncStream requires the raw type as an argument, in the form "RawType.self"."#)
    }
    
    guard let tupleExpr = arguments.dropFirst().first?.as(TupleExprElementSyntax.self),
          let stringLiteral = tupleExpr.expression.as(StringLiteralExprSyntax.self),
          stringLiteral.segments.count == 1,
          case let .stringSegment(varName) = stringLiteral.segments.first
    else {
      throw CustomError.message("@CreateAsyncStream variable name parse failed")
    }
        
    return [
      "public var \(raw: varName): AsyncStream<\(rawType)> { _\(raw: varName) }",
      "private let (_\(raw: varName), _\(raw: varName)Continuation) = AsyncStream.makeStream(of: \(raw: rawType).self)"
    ]
  }
}

@main
struct CreateAsyncStreamPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    CreateAsyncStreamMacro.self
  ]
}


