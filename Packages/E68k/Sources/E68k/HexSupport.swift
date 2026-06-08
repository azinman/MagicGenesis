//
//  HexSupport.swift
//  E68k
//
//  Created by Aaron Zinman on 6/6/26.
//

extension Int {
    var hexValue: String {
        String(self, radix: 16, uppercase: true)
    }
    
    var paddedHexValue: String {
        String(format: "%08X", self)
    }
}

extension Int32 {
    var hexValue: String {
        String(self, radix: 16, uppercase: true)
    }
    
    var paddedHexValue: String {
        String(format: "%08X", self)
    }
}

extension Int16 {
    var hexValue: String {
        String(self, radix: 16, uppercase: true)
    }
    
    var paddedHexValue: String {
        String(format: "%04X", self)
    }
}

extension Int8 {
    var hexValue: String {
        String(self, radix: 16, uppercase: true)
    }
    
    var paddedHexValue: String {
        String(format: "%02X", self)
    }
}

extension UInt {
    var hexValue: String {
        String(self, radix: 16, uppercase: true)
    }
    
    var paddedHexValue: String {
        String(format: "%08X", self)
    }
}

extension UInt32 {
    var hexValue: String {
        String(self, radix: 16, uppercase: true)
    }
    
    var paddedHexValue: String {
        String(format: "%08X", self)
    }
}

extension UInt16 {
    var hexValue: String {
        String(self, radix: 16, uppercase: true)
    }
    
    var paddedHexValue: String {
        String(format: "%04X", self)
    }
}

extension UInt8 {
    var hexValue: String {
        String(self, radix: 16, uppercase: true)
    }
    
    var paddedHexValue: String {
        String(format: "%02X", self)
    }
}
