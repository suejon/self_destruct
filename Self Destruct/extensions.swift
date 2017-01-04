//
//  extensions.swift
//  Self Destruct
//
//  Created by Jono Sue on 31/12/16.
//  Copyright © 2016 Remote Hamster. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1.0)
    }
}

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func loadImageUsingCacheWith(urlString: String) {
        
        self.image = nil
        
        // Check the cache for an image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) {
            self.image = cachedImage as? UIImage
            return
        }
        
        // Image is not in cache, so download
        let request = URLRequest(url: URL(string: urlString)!)
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print("Failed to download image: ", error!)
                return
            }
            
            DispatchQueue.main.async {
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    self.image = downloadedImage
                }
            }
        }
        task.resume()
    }
}
