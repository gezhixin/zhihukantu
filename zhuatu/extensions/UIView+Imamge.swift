//
//  UIView+Imamge.swift
//  ydzs
//
//  Created by 葛枝鑫 on 16/1/24.
//  Copyright © 2016年 葛枝鑫. All rights reserved.
//

import UIKit

extension UIView {

    /// - returns: the bitmap that represents the chart.
    public func getImage(_ transparent: Bool) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque || !transparent, UIScreen.main.scale)
        
        let context = UIGraphicsGetCurrentContext()
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: self.bounds.size)
        
        if (isOpaque || !transparent)
        {
            context?.setFillColor(UIColor.white.cgColor)
            context?.fill(rect)
            
            if (self.backgroundColor !== nil)
            {
                context?.setFillColor((self.backgroundColor?.cgColor)!)
                context?.fill(rect)
            }
        }
        
        if let context = context
        {
            layer.render(in: context)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    public enum ImageFormat
    {
        case jpeg
        case png
    }
    
    /// Saves the current chart state with the given name to the given path on
    /// the sdcard leaving the path empty "" will put the saved file directly on
    /// the SD card chart is saved as a PNG image, example:
    /// saveToPath("myfilename", "foldername1/foldername2")
    ///
    /// - parameter filePath: path to the image to save
    /// - parameter format: the format to save
    /// - parameter compressionQuality: compression quality for lossless formats (JPEG)
    ///
    /// - returns: true if the image was saved successfully
    public func saveToPath(_ path: String, format: ImageFormat, compressionQuality: Double) -> Bool
    {
        let image = getImage(format != .jpeg)

        var imageData: Data!
        switch (format)
        {
        case .png:
            imageData = UIImagePNGRepresentation(image)
            break
            
        case .jpeg:
            imageData = UIImageJPEGRepresentation(image, CGFloat(compressionQuality))
            break
        }

        return ((try? imageData.write(to: URL(fileURLWithPath: path), options: [.atomic])) != nil)
    }
    
    /// Saves the current state of the chart to the camera roll
    public func saveToCameraRoll()
    {
        UIImageWriteToSavedPhotosAlbum(getImage(false), nil, nil, nil)
    }
}
