//
//  ImageViewModel.swift
//  PhotoGrid
//
//  Created by Astha Ameta on 8/19/21.
//

import Foundation
import UIKit

class ImageViewModel: NSObject {
    
    let url = "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY&count=42"
    weak var vc: ViewController?
    var arrOfImgURL = [String]()
    var dataModel = [DataModel]()
    var model = [Model]()
    func performRequest() {
        let semaphore = DispatchSemaphore(value: 0)
        if let urlString = URL(string: url) {
            let session = URLSession.shared
            let dataTask = session.dataTask(with: urlString) {[self] (data, response, error) in
                if error != nil {
                    print(error?.localizedDescription)
                    semaphore.signal()
                }
                if let safeData = data {
                    do {
                        let decodedData = try JSONDecoder().decode([DataModel].self, from: safeData)
                        print(decodedData)
                        self.dataModel.append(contentsOf: decodedData)
                        for item in decodedData {
                            let hurl = Model(url: item.url)
                            self.model.append(hurl)
                            self.arrOfImgURL.append(item.url)
                        }
                        DispatchQueue.main.async {
                            self.vc?.imagesCollectionView.reloadData()
                        }
                    }
                    catch DecodingError.dataCorrupted(let context) {
                        print(context)
                    } catch DecodingError.keyNotFound(let key, let context) {
                        print("Key '\(key)' not found:", context.debugDescription)
                        print("codingPath:", context.codingPath)
                    } catch DecodingError.valueNotFound(let value, let context) {
                        print("Value '\(value)' not found:", context.debugDescription)
                        print("codingPath:", context.codingPath)
                    } catch DecodingError.typeMismatch(let type, let context)  {
                        print("Type '\(type)' mismatch:", context.debugDescription)
                        print("codingPath:", context.codingPath)
                    } catch {
                        print("error: ", error)
                    }
                    semaphore.signal()
                }
                
            }.resume()
            _ = semaphore.wait(timeout: .distantFuture)
        }
    }
    
    func numberOfImages() -> Int {
        return model.count
    }
}
