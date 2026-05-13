//
//  LevelGenerator.swift
//  Astrocat
//
//  Created by Valentino Manuel Gunawan on 07/05/26.
//

import CoreGraphics
import GameplayKit

struct GeneratedPlatform {
    let position: CGPoint
    let textureName: String
    let type: PlatformType
}

enum PlatformType {
    case backbone
    case bridge
    case start
    case decoration
}

struct GeneratedLevel {
    let platforms: [GeneratedPlatform]
    let startPositions: [CGPoint]
}

class LevelGenerator {
    private struct PlatformCell {
        let column: Int
        let row: Int
        let offsetX: CGFloat
        let offsetY: CGFloat
    }
    
    private struct CellKey: Hashable {
        let column: Int
        let row: Int
    }
    
    private enum Zone {
        case left, center, right
    }
    
    private let config: LevelConfig
    private let randomSource: GKLinearCongruentialRandomSource
    
    private var occupiedCells = Set<CellKey>()
    private var platformsByRow: [Int: [PlatformCell]] = [:]
    
    private let safeMinColumn: Int = 1
    private var safeMaxColumn: Int {
        config.gridColumns - 2
    }
    
    private var gridCellWidth: CGFloat {
        config.mapWidth / CGFloat(config.gridColumns)
    }
    
    private var gridRowHeight: CGFloat {
        config.finishLineY / CGFloat(config.gridRows + 2)
    }
    
    init(config: LevelConfig, seed: UInt64) {
        self.config = config
        self.randomSource = GKLinearCongruentialRandomSource(seed: seed)
    }
    
    func generate() -> GeneratedLevel {
        occupiedCells.removeAll()
        platformsByRow.removeAll()
        
        var allCells: [PlatformCell] = []
        
        // Starting area
        let (starts, _, backboneEntry) = generateStartingArea(allCells: &allCells)
        let startCount = 2
        let bridgeCount = allCells.count
        
        placeCell(backboneEntry, into: &allCells)
        
        // Backbone (from entry row + 1 to top)
        _ = generateBackbone(from: backboneEntry, allCells: &allCells)
        let backboneCount = allCells.count
        
        // Decorations
        let decorations = generateDecorations()
        for cell in decorations {
            placeCell(cell, into: &allCells)
        }
        
//        let platforms = allCells.map { createPlatform(from: $0) }
        
        let platforms = allCells.enumerated().map { index, cell -> GeneratedPlatform in
            let type: PlatformType
            if index < startCount {
                type = .start
            } else if index < bridgeCount {
                type = .bridge
            } else if index < backboneCount {
                type = .backbone
            } else {
                type = .decoration
            }
            return GeneratedPlatform(
                position: worldPosition(for: cell),
                textureName: "PlatformEarth",
                type: type
            )
        }
        
        let playerHalfHeight: CGFloat = 32 // 64x64
        let floorTopY = config.startY + config.floorSize.height / 2
        
        let centerStart = CGPoint(
            x: config.mapWidth / 2,
            y: floorTopY + playerHalfHeight + 2
        )
        let perPlatformStarts = starts.map { cell -> CGPoint in
            CGPoint(
                x: worldPosition(for: cell).x,
                y: floorTopY + playerHalfHeight + 2
            )
        }
        let startPositions = [centerStart] + perPlatformStarts
        
        return GeneratedLevel(
            platforms: platforms,
            startPositions: startPositions
        )
    }
    
    // MARK: - Starting Area
    /*
     Starting Patterns:
     - Pattern 0: V-Shape
     - Pattern 1: Left Side
     - Pattern 2: Right Side
     - Pattern 3: Uneven Start (Asymmetric)
     - Pattern 4: Center Start
     */
    private enum StartPattern: Int, CaseIterable {
        case vShape = 0
        case leftLeaning
        case rightLeaning
        case asymmetric
        case centerCluster
    }
    
    private func generateStartingArea(allCells: inout [PlatformCell]) -> (starts: [PlatformCell], bridges: [PlatformCell], entry: PlatformCell) {
        let pattern = StartPattern(rawValue: nextRandomInt(0...4))!
//        let pattern = StartPattern.asymmetric
        
        let (leftCol, rightCol, entryCol) = startingColumn(for: pattern)
        let leftStart = makeCell(column: leftCol, row: 1, offsetRange: 15)
        let rightStart = makeCell(column: rightCol, row: 1, offsetRange: 15)
        
        placeCell(leftStart, into: &allCells)
        placeCell(rightStart, into: &allCells)
        
        var bridges: [PlatformCell] = []
        var leftMaxRow = 2
        var rightMaxRow = 2
        
        var leftBridges = buildBridge(from: leftStart, towardColumn: entryCol, startRow: 2, maxRowUsed: &leftMaxRow, allCells: &allCells)
        var rightBridges = buildBridge(from: rightStart, towardColumn: entryCol, startRow: 2, maxRowUsed: &rightMaxRow, allCells: &allCells)
        
        let maxBridgeRow = max(leftMaxRow, rightMaxRow)
        let entryRow = bridges.isEmpty && leftBridges.isEmpty && rightBridges.isEmpty ? 2 : maxBridgeRow
        
        leftBridges = extendBridge(leftBridges, from: leftStart, toRow: entryRow - 1, targetCol: entryCol, allCells: &allCells)
        rightBridges = extendBridge(rightBridges, from: rightStart, toRow: entryRow - 1, targetCol: entryCol, allCells: &allCells)
        
        bridges.append(contentsOf: leftBridges)
        bridges.append(contentsOf: rightBridges)
        
        var entryCell = makeCell(column: entryCol, row: entryRow, offsetRange: 15)
        
        let lastLeft = leftBridges.last ?? leftStart
        let lastRight = rightBridges.last ?? rightStart
        
        if !isReachable(from: lastLeft, to: entryCell) && !isReachable(from: lastRight, to: entryCell) {
            entryCell = PlatformCell(column: entryCol, row: entryRow, offsetX: 0, offsetY: 0)
        }
        

        return (starts: [leftStart, rightStart], bridges: bridges, entry: entryCell)
    }
    
    private func startingColumn(for pattern: StartPattern) -> (left: Int, right: Int, entry: Int) {
        let mid = (safeMinColumn + safeMaxColumn) / 2

        switch pattern {
        case .vShape:
            // Wide spread, entry at center
            let left = clamp(safeMinColumn + nextRandomInt(0...1), min: safeMinColumn, max: safeMaxColumn)
            let right = clamp(safeMaxColumn - nextRandomInt(0...1), min: mid + 1, max: safeMaxColumn)
            let entry = clamp(mid + nextRandomInt(-1...1), min: safeMinColumn, max: safeMaxColumn)
            return (left, right, entry)

        case .leftLeaning:
            // Start and entry are mostly on the left side
            let left = clamp(safeMinColumn + nextRandomInt(0...1), min: safeMinColumn, max: mid - 2)
            let right = clamp(mid + nextRandomInt(-1...0), min: left + 2, max: safeMaxColumn)
            let entry = clamp(left + nextRandomInt(1...2), min: safeMinColumn, max: safeMaxColumn)
            return (left, right, entry)

        case .rightLeaning:
            // Start and entry are mostly on the right side
            let right = clamp(safeMaxColumn - nextRandomInt(0...1), min: mid + 2, max: safeMaxColumn)
            let left = clamp(mid + nextRandomInt(0...1), min: mid, max: right - 2)
            let entry = clamp(right - nextRandomInt(1...2), min: safeMinColumn, max: safeMaxColumn)
            return (left, right, entry)

        case .asymmetric:
            // Wide spread like V, but entry biased toward one side randomly
            let left = clamp(safeMinColumn + nextRandomInt(0...1), min: safeMinColumn, max: mid - 1)
            let right = clamp(safeMaxColumn - nextRandomInt(0...1), min: mid + 1, max: safeMaxColumn)
            let biasLeft = nextRandom(in: 0...1) < 0.5
            let entry = biasLeft
                ? clamp(left + nextRandomInt(1...2), min: safeMinColumn, max: safeMaxColumn)
                : clamp(right - nextRandomInt(1...2), min: safeMinColumn, max: safeMaxColumn)
            return (left, right, entry)

        case .centerCluster:
            // Both starts middle, minimal bridging
            let left = clamp(mid - nextRandomInt(1...2), min: safeMinColumn, max: mid - 1)
            let right = clamp(mid + nextRandomInt(1...2), min: mid + 1, max: safeMaxColumn)
            let entry = clamp(mid + nextRandomInt(-1...1), min: safeMinColumn, max: safeMaxColumn)
            return (left, right, entry)
        }
    }
    
    // Create bridge path from start platform to entry column
    private func buildBridge(
        from start: PlatformCell,
        towardColumn targetCol: Int,
        startRow: Int,
        maxRowUsed: inout Int,
        allCells: inout [PlatformCell]
    ) -> [PlatformCell] {
        var bridges: [PlatformCell] = []
        var currentCol = start.column
        var previousCell = start
        var row = startRow
        
        while currentCol != targetCol {
            if currentCol < targetCol {
                currentCol += 1
            } else {
                currentCol -= 1
            }
            
            let cell = makeCell(column: currentCol, row: row, offsetRange: 15)
            
            if isReachable(from: previousCell, to: cell) {
                bridges.append(cell)
                placeCell(cell, into: &allCells)
                previousCell = cell
            } else {
                let fallback = PlatformCell(column: currentCol, row: row, offsetX: 0, offsetY: 0)
                bridges.append(fallback)
                placeCell(fallback, into: &allCells)
                previousCell = fallback
            }
            
            row += 1
        }
        
        maxRowUsed = row
        return bridges
    }
    
    // Add extra platforms so left and right reach similar height
    private func extendBridge(
        _ bridge: [PlatformCell],
        from start: PlatformCell,
        toRow targetRow: Int,
        targetCol: Int,
        allCells: inout [PlatformCell]
    ) -> [PlatformCell] {
        var result = bridge
        var previous = bridge.last ?? start
        
        while previous.row < targetRow {
            let nextRow = previous.row + 1
            
            var col = previous.column
            if col < targetCol {
                col += 1
            } else if col > targetCol {
                col -= 1
            }
            
            let cell = makeCell(column: col, row: nextRow, offsetRange: 15)
            
            if isReachable(from: previous, to: cell) {
                result.append(cell)
                placeCell(cell, into: &allCells)
                previous = cell
            } else {
                let fallback = PlatformCell(column: col, row: nextRow, offsetX: 0, offsetY: 0)
                result.append(fallback)
                placeCell(fallback, into: &allCells)
                previous = fallback
            }
        }
        
        return result
    }
    
    // MARK: - Backbone Generation
    
    private func generateBackbone(from entry: PlatformCell, allCells: inout [PlatformCell]) -> [PlatformCell] {
        var cells: [PlatformCell] = []
        
        let maxRow = config.gridRows - 1
        var currentCol = entry.column
        var previousCell = entry
        var consecutiveSameColumn = 0
        
        // Momentum state
        var lastDirection = nextRandom(in: 0...1) < 0.5 ? -1 : 1
        var lastWasSameColumn = false
        
        // Zone state
        var currentZone = zone(for: currentCol)
        var stepsInZone = 0
        
        for row in (entry.row + 1)...maxRow {
            let direction = chooseBackboneDirection(
                currentColumn: currentCol,
                lastDirection: lastDirection,
                lastWasSameColumn: lastWasSameColumn,
                consecutiveSameColumn: consecutiveSameColumn,
                stepsInZone: stepsInZone,
                currentZone: currentZone
            )
            
            let targetCol = clamp(
                currentCol + direction,
                min: safeMinColumn,
                max: safeMaxColumn
            )
            
            let cell = makeCell(column: targetCol, row: row)
            
            if isReachable(from: previousCell, to: cell) && isCellFree(cell) && !wouldStack(column: targetCol, row: row) {
                cells.append(cell)
                placeCell(cell, into: &allCells)
                updateBackboneState(
                    from: currentCol,
                    to: targetCol,
                    lastDirection: &lastDirection,
                    lastWasSameColumn: &lastWasSameColumn,
                    consecutiveSameColumn: &consecutiveSameColumn,
                    stepsInZone: &stepsInZone,
                    currentZone: &currentZone
                )
                currentCol = targetCol
                previousCell = cell
                continue
            }
            
            // Fallback
            var placed = false
            for fallbackDir in [lastDirection, -lastDirection, 0] {
                let fallbackCol = clamp(
                    currentCol + fallbackDir,
                    min: safeMinColumn,
                    max: safeMaxColumn
                )
                let fallbackCell = makeCell(column: fallbackCol, row: row)
                
                if isReachable(from: previousCell, to: fallbackCell) && isCellFree(fallbackCell) && !wouldStack(column: fallbackCol, row: row) {
                    cells.append(fallbackCell)
                    placeCell(fallbackCell, into: &allCells)
                    updateBackboneState(
                        from: currentCol,
                        to: fallbackCol,
                        lastDirection: &lastDirection,
                        lastWasSameColumn: &lastWasSameColumn,
                        consecutiveSameColumn: &consecutiveSameColumn,
                        stepsInZone: &stepsInZone,
                        currentZone: &currentZone
                    )
                    currentCol = fallbackCol
                    previousCell = fallbackCell
                    placed = true
                    break
                }
            }
            
            if !placed {
                let fallbackCell = PlatformCell(
                    column: currentCol,
                    row: row,
                    offsetX: 0,
                    offsetY: 0
                )
                cells.append(fallbackCell)
                placeCell(fallbackCell, into: &allCells)
                lastWasSameColumn = true
                consecutiveSameColumn += 1
                stepsInZone += 1
                previousCell = fallbackCell
            }
        }
        
        return cells
    }
    
    private func wouldStack(column: Int, row: Int) -> Bool {
        // Check row above
        if let aboveCells = platformsByRow[row - 1] {
            if aboveCells.contains(where: { $0.column == column }) {
                return true
            }
        }
        // Check row below
        if let belowCells = platformsByRow[row + 1] {
            if belowCells.contains(where: { $0.column == column }) {
                return true
            }
        }
        return false
    }
    
    private func chooseBackboneDirection(
        currentColumn: Int,
        lastDirection: Int,
        lastWasSameColumn: Bool,
        consecutiveSameColumn: Int,
        stepsInZone: Int,
        currentZone: Zone
    ) -> Int {
        // Choose direction when near map edge
        if currentColumn <= safeMinColumn { return 1 }
        if currentColumn >= safeMaxColumn { return -1 }
        
        // Zone forcing
        if stepsInZone >= 4 {
            switch currentZone {
            case .left: return 1
            case .right: return -1
            case .center: return lastDirection
            }
        }
        
        // Force direction change
        if lastWasSameColumn || consecutiveSameColumn >= 2 {
            return nextRandom(in: 0...1) < 0.5 ? -1 : 1
        }
        
        // Momentum weights: 55% continue, 40% reverse, 5% hold
        let roll = nextRandom(in: 0...100)
        if roll < 55 { return lastDirection }
        else if roll < 95 { return -lastDirection }
        else { return 0 }
    }
    
    private func updateBackboneState(
        from oldCol: Int,
        to newCol: Int,
        lastDirection: inout Int,
        lastWasSameColumn: inout Bool,
        consecutiveSameColumn: inout Int,
        stepsInZone: inout Int,
        currentZone: inout Zone
    ) {
        let move = newCol - oldCol
        lastWasSameColumn = (move == 0)
        
        if move == 0 {
            consecutiveSameColumn += 1
        } else {
            consecutiveSameColumn = 0
            lastDirection = move > 0 ? 1 : -1
        }
        
        let newZone = zone(for: newCol)
        if newZone == currentZone {
            stepsInZone += 1
        } else {
            stepsInZone = 0
            currentZone = newZone
        }
    }
    
    // MARK: - Decoration
    
    private func generateDecorations() -> [PlatformCell] {
        var decorations: [PlatformCell] = []
        let maxRow = config.gridRows - 1
        
        // Store all column in that row
        var columnsOnRow: [Int: Set<Int>] = [:]
        for (row, cells) in platformsByRow {
            columnsOnRow[row] = Set(cells.map { $0.column })
        }
        
        for row in 1...maxRow {
            guard platformCountOnRow(row) < config.maxPlatformsPerRow else { continue }
            
            guard nextRandom(in: 0...100) < config.decorationProbability else { continue }
            
            let sourceCells = platformsByRow[row - 1] ?? []
            guard !sourceCells.isEmpty else { continue }
            
            let sameRowCols = columnsOnRow[row] ?? []
            let aboveRowCols = columnsOnRow[row + 1] ?? []
            let belowRowCols = columnsOnRow[row - 1] ?? []
            
            for _ in 0..<20 {
                let col = nextRandomInt(safeMinColumn...safeMaxColumn)
                
                // Must be at least 2 columns from any platform on same row
                if sameRowCols.contains(where: { abs(col - $0 ) < 2 }){
                    continue
                }
                
                // Must not stack directly above or below a backbone platform
                if aboveRowCols.contains(col) || belowRowCols.contains(col) {
                    continue
                }
                
                let cell = makeCell(column: col, row: row)
                guard isCellFree(cell) else { continue }
                
                // Must be reachable from below
                let reachable = sourceCells.contains { isReachable(from: $0, to: cell) }
                guard reachable else { continue }
                
                decorations.append(cell)
                break
            }
        }
        
        return decorations
    }
    
    // MARK: - Zone Helpers
    
    private func zone(for column: Int) -> Zone {
        let range = safeMaxColumn - safeMinColumn + 1
        let third = CGFloat(range) / 3.0
        let relative = CGFloat(column - safeMinColumn)
        
        if relative < third { return .left }
        if relative < third * 2.0 { return .center }
        return .right
    }
    
    // MARK: - Reachability
    
    private func isReachable(from previous: PlatformCell, to next: PlatformCell) -> Bool {
        let rowGap = next.row - previous.row
        
        let prevPos = worldPosition(for: previous)
        let nextPos = worldPosition(for: next)
        
        let dx = abs(nextPos.x - prevPos.x)
        
        if rowGap == 0 {
            return dx <= gridCellWidth * 2.0
        }
        
        if rowGap == 1 {
            return dx <= gridCellWidth * 1.5
        }
        
        return false
    }
    
    // MARK: - Cell Helpers
    
    private func makeCell(column: Int, row: Int, offsetRange: CGFloat = 30) -> PlatformCell {
        let clampedCol = clamp(
            column,
            min: safeMinColumn,
            max: safeMaxColumn
        )
        
        var offX = nextRandom(in: -offsetRange...offsetRange)
        let offY = nextRandom(in: -8...8)
        
        let rawX = CGFloat(clampedCol) * gridCellWidth + gridCellWidth / 2 + offX
        let margin = config.platformSize.width / 2 + 20
        let minX = margin
        let maxX = config.mapWidth - margin
        if rawX < minX {
            offX += (minX - rawX)
        } else if rawX > maxX {
            offX -= (rawX - maxX)
        }
        
        return PlatformCell(
            column: clampedCol,
            row: row,
            offsetX: offX,
            offsetY: offY
        )
    }
    
    private func key(for cell: PlatformCell) -> CellKey {
        CellKey(column: cell.column, row: cell.row)
    }
    
    private func worldPosition(for cell: PlatformCell) -> CGPoint {
        let x = CGFloat(cell.column) * gridCellWidth + gridCellWidth / 2 + cell.offsetX
        let y = config.startY + CGFloat(cell.row) * gridRowHeight + cell.offsetY
        return CGPoint(x: x, y: y)
    }
    
    private func isCellFree(_ cell: PlatformCell) -> Bool {
        guard cell.column >= 0, cell.column < config.gridColumns else  { return false }
        guard cell.row >= 0, cell.row < config.gridRows else { return false }
        return !occupiedCells.contains(key(for: cell))
    }
    
    private func placeCell(_ cell: PlatformCell, into list: inout [PlatformCell]) {
        let k = key(for: cell)
        guard !occupiedCells.contains(k) else { return }
        occupiedCells.insert(k)
        platformsByRow[cell.row, default: []].append(cell)
        list.append(cell)
    }
    
    private func platformCountOnRow(_ row: Int) -> Int {
        platformsByRow[row]?.count ?? 0
    }
    
    private func createPlatform(from cell: PlatformCell, type: PlatformType) -> GeneratedPlatform {
        GeneratedPlatform(
            position: worldPosition(for: cell),
            textureName: "PlatformEarth",
            type: type
        )
    }

    // MARK: - Random Helpers
    
    private func nextRandom(in range: ClosedRange<CGFloat>) -> CGFloat {
        let f = randomSource.nextUniform()
        return range.lowerBound + CGFloat(f) * (range.upperBound - range.lowerBound)
    }
    
    private func nextRandomInt(_ range: ClosedRange<Int>) -> Int {
        let lower = range.lowerBound
        let upper = range.upperBound
        guard upper >= lower else { return lower }
        
        let count = upper - lower + 1
        return lower + randomSource.nextInt(upperBound: count)
    }
    
    private func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat {
        a + (b - a) * min(max(t, 0), 1)
    }
    
    private func clamp(_ value: Int, min minValue: Int, max maxValue: Int) -> Int {
        Swift.min(Swift.max(value, minValue), maxValue)
    }
}
