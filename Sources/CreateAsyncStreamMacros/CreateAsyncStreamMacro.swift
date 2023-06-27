import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

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
    // FIXME: currently only used on a class but want to allow on a struct also?
    guard declaration.as(ClassDeclSyntax.self) != nil else {
      throw CustomError.message("@CreateAsyncStream only works on classes")
    }
    
    guard let arguments = Syntax(node.argument)?.children(viewMode: .fixedUp) else {
      throw CustomError.message("@CreateAsyncStream arguments error")
    }
    
    guard let tupleExpr = arguments.first?.as(TupleExprElementSyntax.self),
          let typeName = tupleExpr.expression.as(IdentifierExprSyntax.self)?.identifier.text
    else {
      throw CustomError.message("@CreateAsyncStream typeName argument parse failed")
    }

    guard let tupleExpr = arguments.dropFirst().first?.as(TupleExprElementSyntax.self),
          let varName = tupleExpr.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue
    else {
      throw CustomError.message("@CreateAsyncStream variable name parse failed")
    }
    
    // building these up by string interpolation seems a little unstructured but that does seem to be common.
    // I'd feel better if we were building the correct datatypes explicitly (VariableDeclSyntax ?)
    
    return [
      "public var \(raw: varName): AsyncStream<\(raw: typeName)> { _\(raw: varName) }",
      "private let (_\(raw: varName), _\(raw: varName)Continuation) = AsyncStream.makeStream(of: \(raw: typeName).self)"
    ]
  }
}

@main
struct CreateAsyncStreamPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    CreateAsyncStreamMacro.self
  ]
}


