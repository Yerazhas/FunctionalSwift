import UIKit

typealias Distance = Double

struct Position {
    var x: Double
    var y: Double
    
    func within(range: Distance) -> Bool {
        return sqrt(x * x + y * y) <= range
    }
}

extension Position {
    func minus(_ p: Position) -> Position {
        return Position(x: x - p.x, y: y - p.y)
    }
    
    var length: Distance {
        return sqrt(x * x + y * y)
    }
}

struct Ship {
    var position: Position
    var firingRange: Distance
    var unsafeRange: Distance
    
    func canEngage(ship target: Ship, friendly: Ship) -> Bool {
        let targetDistance = target.position.minus(position).length
        let friendlyDistance = friendly.position.minus(target.position).length
        
        return targetDistance <= firingRange && targetDistance > unsafeRange && (friendlyDistance > unsafeRange)
    }
}

func pointInRange(point: Position) -> Bool {
    return true
}

//typealias Region = (Position) -> Bool

struct Region {
    let lookup: (Position) -> Bool
}

func circle(radius: Distance) -> Region {
    return Region(lookup: { point in point.length <= radius })
}

func circle2(radius: Distance, center: Position) -> Region {
    return Region(lookup: { point in point.minus(center).length <= radius })
}

extension Region {
    func shift( by offset: Position) -> Region {
        return Region(lookup: { point in self.lookup(point.minus(offset)) })
    }
    func invert() -> Region {
        return Region(lookup: { point in !self.lookup(point) })
    }
    
    func intersect(with other:  Region) -> Region {
        return Region(lookup: { point in self.lookup(point) && other.lookup(point) })
    }
    
    func union(with other: Region) -> Region {
        return Region(lookup: { point in self.lookup(point) || other.lookup(point) })
    }
    
    func subtract(from original: Region) -> Region {
        return original.intersect(with: self.invert())
    }
}

let shifted = circle(radius: 6).shift(by: Position(x: 5, y: 5))
shifted.lookup(Position(x: 9, y: 2))

extension Ship {
    func canSafelyEngageShip(target: Ship, friendly: Ship) -> Bool {
        let rangeRegion = circle(radius: unsafeRange).subtract(from: circle(radius: firingRange))
        let firingRegion = rangeRegion.shift(by: position)
        let friendlyRegion = circle(radius: unsafeRange).shift(by: friendly.position)
        let resultRegion = friendlyRegion.subtract(from: firingRegion)
        
        return resultRegion.lookup(target.position)
    }
}

