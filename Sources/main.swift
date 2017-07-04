import Foundation
import OrbitCompilerUtils
import OrbitFrontend

let usage = "Usage: orb <command> [options]\n\tUse orb help for more info"

if CommandLine.argc < 2 {
    print(usage)
    exit(0)
}

class SourceResolver : CompilationPhase {
    typealias InputType = String
    typealias OutputType = String
    
    func execute(input: String) throws -> String {
        guard let source = FileManager.default.contents(atPath: input) else {
            throw OrbitError(message: "Could not find Orbit source file at \(input)")
        }
        
        guard let str = String(data: source, encoding: .utf8) else { throw OrbitError(message: "Could not open source file: \(input)") }
        
        return str
    }
}

let source = SourceResolver()
let lexer = Lexer()
let parser = Parser()

let chain1 = CompilationChain<Lexer, Parser>(inputPhase: lexer, outputPhase: parser)
let chain2 = CompilationChain<SourceResolver, CompilationChain<Lexer, Parser>>(inputPhase: source, outputPhase: chain1)

do {
    let ast = try chain2.execute(input: CommandLine.arguments[1])
    print(ast)
} catch let ex as OrbitError {
    print(ex.message)
} catch let ex {
    print(ex)
}
