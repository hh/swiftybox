import Foundation

/// Test command - Evaluate conditional expression
/// Usage: test EXPRESSION
///        [ EXPRESSION ]
/// Evaluates conditional expressions and returns 0 (true) or 1 (false)
struct TestCommand {
    static func main(_ args: [String]) -> Int32 {
        // Handle [ command - last arg should be ]
        var expression = Array(args[1...])

        if args[0].hasSuffix("[") {
            guard expression.last == "]" else {
                FileHandle.standardError.write("[: missing ']'\n".data(using: .utf8)!)
                return 2
            }
            expression = Array(expression.dropLast())
        }

        if expression.isEmpty {
            return 1  // Empty expression is false
        }

        do {
            let result = try evaluate(expression: expression)
            return result ? 0 : 1
        } catch {
            FileHandle.standardError.write("test: \(error.localizedDescription)\n".data(using: .utf8)!)
            return 2
        }
    }

    enum TestError: Error, LocalizedError {
        case invalidExpression(String)
        case missingArgument(String)

        var errorDescription: String? {
            switch self {
            case .invalidExpression(let msg): return msg
            case .missingArgument(let msg): return msg
            }
        }
    }

    static func evaluate(expression: [String]) throws -> Bool {
        guard !expression.isEmpty else { return false }

        // Single argument - test if non-empty string
        if expression.count == 1 {
            return !expression[0].isEmpty
        }

        // Two arguments - unary operators
        if expression.count == 2 {
            let op = expression[0]
            let arg = expression[1]

            if op == "!" {
                return try !evaluate(expression: [arg])
            }

            // Try to evaluate as unary operator
            return try evaluateUnary(op: op, arg: arg)
        }

        // Three arguments - could be unary operator or binary comparison
        if expression.count == 3 {
            // Check if negation
            if expression[0] == "!" {
                return try !evaluate(expression: Array(expression[1...]))
            }

            let left = expression[0]
            let op = expression[1]
            let right = expression[2]

            // Check if middle argument is a logical operator (AND/OR)
            if op == "-a" {
                // Logical AND
                return try evaluate(expression: [left]) && evaluate(expression: [right])
            }
            if op == "-o" {
                // Logical OR
                return try evaluate(expression: [left]) || evaluate(expression: [right])
            }

            // Check if middle argument is a binary operator
            switch op {
            // String comparisons
            case "=", "==": return left == right
            case "!=": return left != right

            // Integer comparisons
            case "-eq": return (Int(left) ?? 0) == (Int(right) ?? 0)
            case "-ne": return (Int(left) ?? 0) != (Int(right) ?? 0)
            case "-gt": return (Int(left) ?? 0) > (Int(right) ?? 0)
            case "-ge": return (Int(left) ?? 0) >= (Int(right) ?? 0)
            case "-lt": return (Int(left) ?? 0) < (Int(right) ?? 0)
            case "-le": return (Int(left) ?? 0) <= (Int(right) ?? 0)

            default:
                // Not a binary operator, try as unary operator with argument
                return try evaluateUnary(op: left, arg: right)
            }
        }

        // Four or more arguments - handle negation and complex expressions
        if expression.count >= 4 {
            if expression[0] == "!" {
                return try !evaluate(expression: Array(expression[1...]))
            }

            // Look for logical operators
            if let andIndex = expression.firstIndex(of: "-a") {
                let left = Array(expression[..<andIndex])
                let right = Array(expression[(andIndex + 1)...])
                return try evaluate(expression: left) && evaluate(expression: right)
            }

            if let orIndex = expression.firstIndex(of: "-o") {
                let left = Array(expression[..<orIndex])
                let right = Array(expression[(orIndex + 1)...])
                return try evaluate(expression: left) || evaluate(expression: right)
            }
        }

        throw TestError.invalidExpression("too many arguments")
    }

    static func evaluateUnary(op: String, arg: String) throws -> Bool {
        let fileManager = FileManager.default
        var isDir: ObjCBool = false

        switch op {
        // String tests
        case "-z": return arg.isEmpty
        case "-n": return !arg.isEmpty

        // File tests
        case "-e", "-a": return fileManager.fileExists(atPath: arg)
        case "-f": return fileManager.fileExists(atPath: arg) && !fileManager.fileExists(atPath: arg, isDirectory: &isDir) || !isDir.boolValue
        case "-d": return fileManager.fileExists(atPath: arg, isDirectory: &isDir) && isDir.boolValue
        case "-r": return fileManager.isReadableFile(atPath: arg)
        case "-w": return fileManager.isWritableFile(atPath: arg)
        case "-x": return fileManager.isExecutableFile(atPath: arg)
        case "-s":
            if let attrs = try? fileManager.attributesOfItem(atPath: arg),
               let size = attrs[.size] as? Int64 {
                return size > 0
            }
            return false
        case "-L", "-h":  // Symbolic link
            if let attrs = try? fileManager.attributesOfItem(atPath: arg) {
                return attrs[.type] as? FileAttributeType == .typeSymbolicLink
            }
            return false

        default:
            throw TestError.invalidExpression("unknown unary operator: \(op)")
        }
    }
}
