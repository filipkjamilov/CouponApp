//  Created by Filip Kjamilov on 30.10.22.

import Foundation
import FirebaseDatabase
import FirebaseStorage
import SwiftUI

final class RemoteRepository {
    
    @Published(key: StorageKeys.displayingContent.rawValue) private(set) var displayingContent: [Content] = []
    @Published(key: StorageKeys.ratedContent.rawValue) private(set) var ratedContent: [Content] = []
    
    @AppStorage(StorageKeys.limit.rawValue) var limit = 5
    @AppStorage(StorageKeys.start.rawValue) var start = 1
    @AppStorage(StorageKeys.endReached.rawValue) var endReached = false
    
    private var storageReference: StorageReference { Storage.storage().reference() }
    private var databaseReference: DatabaseReference { Database.database().reference() }
    
    func fetchContent() {
        
        let databaseQuery = getDatabaseQuery()
        
        databaseQuery.observeSingleEvent(of: .value) { snapshot in

            if snapshot.childrenCount < self.limit {
                self.endReached = true
                self.start = 1
            }
            
            guard let snapshot = snapshot.value as? [String: Any] else { return }
            
            snapshot.forEach { content in
                guard let jsonObject = try? JSONSerialization.data(withJSONObject: content.value as Any,
                                                                   options: []) else { return }
                
                let contentDto: ContentDto
                do {
                    contentDto = try JSONDecoder().decode(ContentDto.self, from: jsonObject)
                } catch {
                    print("Decoding error! -> ", error.localizedDescription)
                    return
                }
                
                self.fetchImageData(with: contentDto.imageName) { imageData in
                    DispatchQueue.main.async {
                        self.displayingContent.append(self.mapContent(contentDto, imageData))
                    }
                }

            }
        }
    }
    
    func fetchImageData(with imageName: String, completion: @escaping (_ imageData: ImageData) -> () ) {
        self.storageReference.child("content/\(imageName)").downloadURL(completion: { url, error in
            
            guard let url = url, error == nil else { return }
            guard let imageLink = URL(string: url.absoluteString) else { return }
            
            URLSession.shared.dataTask(with: imageLink, completionHandler: { data, _, error in
                guard let data = data, error == nil else { return }
                completion(data)
            }).resume()
            
        })
    }
    
    func appendRated(_ content: Content) {
        ratedContent.append(content)
    }
    
    func appendDisplaying(_ content: Content) {
        displayingContent.append(content)
    }
    
    func removeDisplaying(_ content: Content) {
        displayingContent.remove(at: getIndexFromDisplaying(content))
    }
    
    func removeRated(_ content: Content) {
        ratedContent.remove(at: getIndexFromRated(content))
    }
    
    func getIndexFromDisplaying(_ content: Content) -> Int {
        return displayingContent.firstIndex(where: { return content.id == $0.id }) ?? 0
    }
    
    func getIndexFromRated(_ content: Content) -> Int {
        return ratedContent.firstIndex(where: { return content.id == $0.id }) ?? 0
    }
    
    func resetData() {
        displayingContent = []
        ratedContent = []
        endReached = false
        start = 1
    }
    
    // MARK: -
    
    private func getDatabaseQuery() -> DatabaseQuery {
        return databaseReference
            .child("content")
            .queryOrdered(byChild: "id")
            .queryStarting(atValue: start)
            .queryLimited(toFirst: UInt(limit))
    }
    
    private func mapContent(_ dto: ContentDto, _ imageData: ImageData) -> Content {
        return Content(id: dto.id, name: dto.name, imageName: dto.imageName, downloadedImage: imageData)
    }
    
}
