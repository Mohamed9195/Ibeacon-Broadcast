//
//  Snapshot.swift
//  ButterflySDK
//
//  Created by Ahmed Henawey on 6/22/18.
//  Copyright © 2018 Xtrava Inc. All rights reserved.
//

import CoreLocation

//public extension Array where Element == StyleData {
//    var log: String {
//        let rangeDC1Values = self.map({ $0.rangeADC1Description ?? "-"}).joined(separator: ", ")
//        let accuracyValues = self.map({ String(format: "%0.2f", $0.accuracy) }).joined(separator: ", ")
//        
//        return """
//        Other:
//        rangeDC1: [\(rangeDC1Values)]
//        distance: [\(accuracyValues)]
//        """
//    }
//}

public extension StyleData {
  
    public struct Battery: CustomStringConvertible, Codable, Equatable {
        public enum Level: Int, Codable, Comparable {
            case veryLow = 0
            case low = 1
            case medium = 2
            case high = 3
            
            public var percentage: Float {
                switch self {
                case .veryLow:
                    return 15
                    
                case .low:
                    return 35
                    
                case .medium:
                    return 65
                    
                case .high:
                    return 90
                }
            }
            
            public static func < (lhs: StyleData.Battery.Level, rhs: StyleData.Battery.Level) -> Bool {
                return lhs.rawValue < rhs.rawValue
            }
        }
        
        public let level: Level?
        public let isCharging: Bool?
        
        public init(level: Level?, isCharging: Bool?) {
            self.level = level
            self.isCharging = isCharging
        }
        
        public var description: String {
            return level.map({ String($0.rawValue) }) ?? ""
        }
    }
}

public struct StyleData {
    
    static var current = StyleData()
    
    public internal(set) var timestamp: TimeInterval = Date().timeIntervalSince1970
   // public var snapshotType0: SnapshotType0? = nil
   
    
    // TODO: Refactor `rawBytes` by create a separate class/struct for the Snapshot
    // that comes from the Butterfly memory
    
    /// The raw bytes value, this will be nil if the data comes from iBeacon
  //  var rawBytes: [Byte]?
   
//    public var rawBits: [Bit]? {
//        return rawBytes?.flatMap({ $0.bits() })
//    }
    
//    private init() {}
//
//    internal mutating func update(bytes: [Byte]) -> StyleData {
//        if bytes.count > 20 {
//            assertionFailure("the data cannot be more than 20 bytes")
//        }
//
//        self.rawBytes = bytes
//
//        timestamp = Double(Array(bytes[0...3]).reduce(Data()) { (input, byte) -> Data in
//            var input = input
//            input.append(byte)
//            return input
//        }.uint32)
//
//        let majorType0 = bytes.extract(range: 4...5)
//        let minorType0 = bytes.extract(range: 6...7)
//        snapshotType0 = SnapshotType0(major: majorType0, minor: minorType0, accumulateOn: snapshotType0)
//
//        return self
//    }
    
    
//    internal mutating func update(beacon: CLBeacon) -> StyleData {
//        let major = beacon.major.uint16Value.bits()
//        accuracy = beacon.accuracy
//
//        let type = Int(Array(major[0...1]).uint8())
//
//        switch type {
//        case 0:
//            snapshotType0 = SnapshotType0(major: beacon.major.uint16Value.bits(), minor: beacon.minor.uint16Value.bits(), accumulateOn: snapshotType0)
//
//
//        default:
//            break
//        }
//
//        return self
//    }
    
//    public var toggleBit: Bit? {
//        return snapshotType0?.toggleBit
//    }
//
//
//    public var rangeADC1Description: String? {
//        guard let s2 = snapshotType2, let s3 = snapshotType3 else { return nil }
//
//        return logDescription(for: Array(s2.minor[12...15]) + Array(s3.major[4...7]))
//    }
//
//    internal func logDescription(for range: [Bit]) -> String {
//        let sign = range[0] == .zero ? 1 : -1
//        let value = Int(Array(range[1...4]).uint8())
//        let power = Int(Array(range[5...7]).uint8())
//
//        return "\(sign * value)e\(power)"
//    }
//
//    public var battery: Battery {
//        return Battery(
//            level: snapshotType0?.batteryValue.flatMap({Battery.Level(rawValue: $0)}),
//            isCharging: snapshotType0?.isCharging.map({ $0 == 1 })
//        )
//    }
//
//    public var type: Int? {
//        return snapshotType0?.type
//    }
  
//    public var dictionary: [String: Any] {
//        var dictionary: [String: Any] = [:]
//        if let snapshotType0 = snapshotType0 {
//            dictionary += snapshotType0.dictionary
//        }
//        if let snapshotType1 = snapshotType1 {
//            dictionary += snapshotType1.dictionary
//        }
//
//        dictionary["accuracy"] = accuracy
//
//        return dictionary
//    }
    
  
    
//    public var hexadecimalString: String? {
//        guard let bytes = rawBytes else { return nil }
//        return Data(bytes).hexEncodedString()
//    }
}

internal extension Dictionary {
    fileprivate static func +=(lhs: inout [Key: Value], rhs: [Key: Value]) {
        rhs.forEach({ lhs[$0] = $1})
    }
}
