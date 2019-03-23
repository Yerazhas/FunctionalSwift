import UIKit

precedencegroup Group { associativity: left }

infix operator >>>: Group

func >>> <T, U, V> (left: @escaping (T) -> U, right: @escaping (U) -> V) -> (T) -> V {
    return { input in right(left(input)) }
}

func doubleToInt(_ double: Double) -> Int {
    return Int(double)
}

func intToString(_ int: Int) -> String {
    return String(int)
}

let res = (doubleToInt >>> intToString)(5.0)
print(res)
