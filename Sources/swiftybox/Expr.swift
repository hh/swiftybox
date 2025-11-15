import Foundation

/// Expr command - Evaluate expressions
/// Usage: expr EXPRESSION
struct ExprCommand {
    static func main(_ args: [String]) -> Int32 {
        guard args.count > 1 else {
            FileHandle.standardError.write("expr: missing operand\n".data(using: .utf8)!)
            return 1
        }

        let expr = Array(args[1...])

        // Simple expression evaluator
        if expr.count == 3 {
            let left = expr[0]
            let op = expr[1]
            let right = expr[2]

            // Try numeric operations
            if let l = Int(left), let r = Int(right) {
                let result: Int
                switch op {
                case "+": result = l + r
                case "-": result = l - r
                case "*": result = l * r
                case "/": result = r != 0 ? l / r : 0
                case "%": result = r != 0 ? l % r : 0
                case "<": result = l < r ? 1 : 0
                case "<=": result = l <= r ? 1 : 0
                case "=": result = l == r ? 1 : 0
                case "!=": result = l != r ? 1 : 0
                case ">=": result = l >= r ? 1 : 0
                case ">": result = l > r ? 1 : 0
                case "|": result = (l != 0 || r != 0) ? 1 : 0
                case "&": result = (l != 0 && r != 0) ? 1 : 0
                default:
                    FileHandle.standardError.write("expr: unknown operator: \(op)\n".data(using: .utf8)!)
                    return 1
                }
                print(result)
                // Exit code: 0 if result is non-zero (true), 1 if result is zero (false)
                return result == 0 ? 1 : 0
            }

            // String operations
            let result: Int
            switch op {
            case "=": result = left == right ? 1 : 0
            case "!=": result = left != right ? 1 : 0
            case "<": result = left < right ? 1 : 0
            case "<=": result = left <= right ? 1 : 0
            case ">": result = left > right ? 1 : 0
            case ">=": result = left >= right ? 1 : 0
            case "|": result = (!left.isEmpty || !right.isEmpty) ? 1 : 0
            case "&": result = (!left.isEmpty && !right.isEmpty) ? 1 : 0
            default:
                FileHandle.standardError.write("expr: unknown operator: \(op)\n".data(using: .utf8)!)
                return 1
            }
            print(result)
            return result == 0 ? 1 : 0
        }

        // Single value
        if expr.count == 1 {
            print(expr[0])
            return 0
        }

        FileHandle.standardError.write("expr: syntax error\n".data(using: .utf8)!)
        return 1
    }
}
