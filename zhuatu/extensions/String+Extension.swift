//
//  String+PhoneNunber.swift
//  ydzs
//
//  Created by 葛枝鑫 on 16/4/12.
//  Copyright © 2016年 葛枝鑫. All rights reserved.
//

import UIKit

extension String {
    func isPhoneCNMobileNumber() -> Bool {
        let regular = "^1\\d{10}"
        let str = self.absolutePhoneString()
        return str.lengthOfBytes(using: String.Encoding.utf8) == 11 && str.range(of: regular, options: NSString.CompareOptions.regularExpression) != nil
    }
    
    func phoneString4Show() -> String {
        var str = self.absolutePhoneString()
        var i = Int(0)
        while i < str.characters.count && str.characters.count > 2 {
            if i == 3 || (i - 3) % 5 == 0 {
                str = str.insert(" ", ind: i)
            }
            i += 1
        }
        
        return str
    }
    
    func insert(_ string:String, ind:Int) -> String {
        return  String(self.characters.prefix(ind)) + string + String(self.characters.suffix(self.characters.count-ind))
    }
    
    func absolutePhoneString() -> String {
        return self.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal)
    }
    
    func isAvlidPassword() -> Bool {
        let regular = "^[A-Za-z0-9~!@#$%&*()/-_:\"\';,.^ ]{6,22}$"
        let str = self.absolutePhoneString()
        return str.range(of: regular, options: NSString.CompareOptions.regularExpression) != nil
    }
    
    func sizeWith(_ font: UIFont, width: CGFloat) -> CGSize {
        let size = CGSize(width: width, height: 1000000)
        let nsText = NSString(string: self)
        let options : NSStringDrawingOptions = .usesLineFragmentOrigin
        let boundingRect = nsText.boundingRect(with: size, options: options, attributes: [NSFontAttributeName: font], context: nil)
        return boundingRect.size
    }
    
    func md5() -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        if let data = self.data(using: String.Encoding.utf8) {
            CC_MD5((data as NSData).bytes, CC_LONG(data.count), &digest)
        }
        
        var digestHex = ""
        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        
        return digestHex
    }
}
