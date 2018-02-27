import Foundation
import OrbitCompilerUtils
import OrbitFrontend
import OrbitBackend
import SwiftCLI
import SwiftyJSON
import LLVM
import cllvm

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

func validateFileExists(path value: String) throws {
    guard FileManager.default.fileExists(atPath: value) else {
        throw CLI.Error(message: "\(value) does not exist")
    }
}

func validateIsOrbitSourceFile(path value: String) throws {
    let path = URL(fileURLWithPath: value)
    
    guard path.pathExtension == "orb" else {
        throw CLI.Error(message: "Expected file with .orb extension, found: \(value)")
    }
}

let GlobalOutputFile = Key<String>("-o", "--output", description: "Output will be written to this path")

class Lex : Command {
    let name = "lex"
    let inputFile = Parameter()
    let outputFile = GlobalOutputFile
    let shortDescription: String = "Tokenises the given source file"
    
    // TODO - Different output formats
    
    func execute() throws {
        try validateFileExists(path: inputFile.value)
        try validateIsOrbitSourceFile(path: inputFile.value)
        
        let source = SourceResolver()
        let lexer = Lexer()
        
        let chain = CompilationChain(inputPhase: source, outputPhase: lexer)
        
        let result = try chain.execute(input: inputFile.value).map { token in
            return "\(token.type.name) : \(token.value)"
        }.joined(separator: "\n")
        
        if let out = outputFile.value {
            try result.write(toFile: out, atomically: true, encoding: .utf8)
        } else {
            print(result)
        }
    }
}

class Parse : Command {
    let name = "parse"
    let inputFile = Parameter()
    let outputFile = GlobalOutputFile
    let shortDescription: String = "Parses the given source file into an AST"
    
    // TODO - Different output formats, JSON especially
    
    func execute() throws {
        try validateFileExists(path: inputFile.value)
        try validateIsOrbitSourceFile(path: inputFile.value)
        
        let source = SourceResolver()
        let lexer = Lexer()
        let parser = ParseContext.bootstrapParser()
        
        let lexParseChain = CompilationChain(inputPhase: lexer, outputPhase: parser)
        let chain = CompilationChain(inputPhase: source, outputPhase: lexParseChain)
        
        let root = try chain.execute(input: inputFile.value) as! RootExpression
        let result = root.body[0] as! ProgramExpression
        
        if let out = outputFile.value {
            try result.toJson().rawString()!.write(toFile: out, atomically: true, encoding: .utf8)
        } else {
            print(result.toJson().rawString()!)
        }
    }
}

//class Build : Command {
//    let name = "build"
//    let inputFile = Parameter()
//    let outputFile = GlobalOutputFile
//    let shortDescription: String = "Compiles the given source file to an executable binary"
//
//    func run(cmd: String, args: [String]) -> String? {
//        let pipe = Pipe()
//        let process = Process()
//
//        process.launchPath = cmd
//        process.arguments = args
//
//        process.standardOutput = pipe
//
//        let fileHandle = pipe.fileHandleForReading
//
//        process.launch()
//
//        return String(data: fileHandle.readDataToEndOfFile(), encoding: .utf8)
//    }
//
//    func execute() throws {
//        // TODO - Multiple input files, linking
//
//        try validateFileExists(path: inputFile.value)
//        try validateIsOrbitSourceFile(path: inputFile.value)
//
//        let source = SourceResolver()
//        let lexer = Lexer()
//        let parser = Parser()
//        let nameResolver = NameResolver()
//        let methodResolver = MethodResolver()
//        let traitResolver = TraitResolver()
//        let lexParseChain = CompilationChain(inputPhase: lexer, outputPhase: parser)
//        let chain = CompilationChain(inputPhase: source, outputPhase: lexParseChain)
//
//        do {
//            let result = try chain.execute(input: inputFile.value)
//            let typeChecker = TypeResolver()
//            var context = try nameResolver.execute(input: result.body as! [APIExpression])
//
//            context = try methodResolver.execute(input: context)
//            context = try traitResolver.execute(input: context)
//            context = try typeChecker.execute(input: context)
//
//            let codegen = LLVMGenerator()
//            let module = try codegen.execute(input: context)
//
//            let objPath = outputFile.value ?? inputFile.value.replacingOccurrences(of: ".orb", with: ".o")
//            let exePath = inputFile.value.replacingOccurrences(of: ".orb", with: "")
//
//            try TargetMachine().emitToFile(module: module, type: .object, path: objPath)
//
//            guard let clang = run(cmd: "/usr/bin/which", args: ["clang"])?.replacingOccurrences(of: "\n", with: "") else {
//                guard let gcc = run(cmd: "/usr/bin/which", args: ["gcc"])?.replacingOccurrences(of: "\n", with: "") else {
//                    throw OrbitError(message: "Could not find clang or gcc, please ensure")
//                }
//
//                _ = run(cmd: gcc, args: [objPath, "-o \(exePath)"])
//
//                return
//            }
//
//            _ = run(cmd: clang, args: [objPath, "-o", "\(exePath)"])
//        } catch let ex as OrbitError {
//            print(ex.message)
//        } catch let ex {
//            throw ex
//        }
//    }
//}

// JIT is not working correctly, something to do with libffi by the looks of it.
// If we can't get this working, I'll probably write a custom interpreter or VM at some point to remove this dependency,
// which will also be useful for the repl.

//class Run : Command {
//    let name = "run"
//    let inputFile = Parameter()
//    let shortDescription: String = "Compiles & runs the given source file"
//    let args = OptionalCollectedParameter()
//    
//    func execute() throws {
//        try validateFileExists(path: inputFile.value)
//        try validateIsOrbitSourceFile(path: inputFile.value)
//        
//        let source = SourceResolver()
//        let lexer = Lexer()
//        let parser = Parser()
//        
//        let lexParseChain = CompilationChain(inputPhase: lexer, outputPhase: parser)
//        let chain = CompilationChain(inputPhase: source, outputPhase: lexParseChain)
//        
//        let result = try chain.execute(input: inputFile.value)
//        
//        let typeChecker = TypeResolver()
//        
//        do {
//            let typeMap = try typeChecker.execute(input: result)
//            let api = result.body[0] as! APIExpression
//            let codegen = LLVMGenerator(apiName: api.name.value)
//            let module = try codegen.execute(input: (typeMap: typeMap, ast: api))
//            
//            LLVMLinkInMCJIT()
//            
//            let jit = try JIT(module: module, machine: try TargetMachine())
//            
//            guard let mainFunc = module.function(named: "main") else { throw OrbitError(message: "Could not find 'main' function") }
//            
//            // TODO - command line args
//            _ = jit.runFunctionAsMain(mainFunc, args: [])
//        } catch let ex as OrbitError {
//            print(ex.message)
//        } catch let ex {
//            throw ex
//        }
//    }
//}

let cli = CLI(name: "orbit", commands: [Lex(), Parse()]) //, TypeCheck(), LLVM(), Build()])

//_ = cli.debugGo(with: "orbit parse /Users/davie/dev/other/Orb/simple.orb")
_ = cli.go()

