//  Created by Filip Kjamilov on 30.10.22.

import Foundation
import FirebaseDatabase
import FirebaseStorage
import SwiftUI
import Combine

typealias ImageData = Data

public class MainRatingViewModel: ObservableObject {
    
    @Published(key: StorageKeys.displayingContent.rawValue) var displayingContent: [Content] = []
    @Published(key: StorageKeys.ratedContent.rawValue) var ratedContent: [Content] = []
    
    @AppStorage(StorageKeys.showPromoCode.rawValue) var showPromoCode = false
    @AppStorage(StorageKeys.endReached.rawValue) var endReached = false
    @AppStorage(StorageKeys.freshStart.rawValue) var freshStart = true
    @AppStorage(StorageKeys.coupon.rawValue) var coupon = ""
    @AppStorage(StorageKeys.start.rawValue) var start = 1
    @AppStorage(StorageKeys.limit.rawValue) var limit = 5
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - CP
    
    var numRated: Int { ratedContent.count }
    var numLiked: Int { ratedContent.filter({$0.rating == .liked}).count }
    var numDislike: Int { ratedContent.filter({$0.rating == .disliked}).count }
    var numDisplayed: Int { displayingContent.count }
    var isContentEmpty: Bool { displayingContent.isEmpty }
    var storageReference: StorageReference { Storage.storage().reference() }
    var databaseReference: DatabaseReference { Database.database().reference() }
    
    init() {
        if freshStart {
            fetchData()
            freshStart = false
        }
    }
    
    func fetchData() {
        
        let databaseQuery = getDatabaseQuery()
        
        databaseQuery.observeSingleEvent(of: .value) { snapshot in

            if snapshot.childrenCount < self.limit { self.endReached = true }
            guard let snapshot = snapshot.value as? [String: Any] else { return }

            snapshot.forEach { content in
                
                guard let test = try? JSONSerialization.data(withJSONObject: content.value as Any, options: []) else { return }
                
                let dto: ContentDto
                do {
                    dto = try JSONDecoder().decode(ContentDto.self, from: test)
                } catch {
                    print("Decoding error!")
                    return
                }
                
                self.fetchImageData(with: dto.imageName) { imageData in
                    DispatchQueue.main.async {
                        // Append content to array!
                        self.displayingContent.append(self.mapToContent(dto: dto, imageData: imageData))
                    }
                }

            }
        }
    }
    
    func getDatabaseQuery() -> DatabaseQuery {
        return databaseReference
            .child("content")
            .queryOrdered(byChild: "id")
            .queryStarting(atValue: start)
            .queryLimited(toFirst: UInt(limit))
    }
    
    func mapToContent(dto: ContentDto, imageData: ImageData) -> Content {
        return Content(id: dto.id,
                       name: dto.name,
                       imageName: dto.imageName,
                       downloadedImage: imageData)
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
    
    func getIndex(for content: Content) -> Int {
        return displayingContent.firstIndex(where: { return content.id == $0.id }) ?? 0
    }

    func saveRated(content: Content) {
        var rated = content
        rated.downloadedImage = Data()
        ratedContent.append(rated)
        if ratedContent.count >= 30 {
            showPromoCode = true
            retreiveCoupon()
        }
    }
    
    func appReset() {
        // Reset properties
        UserDefaults.standard.reset()
        displayingContent = []
        ratedContent = []
        showPromoCode = false
        endReached = false
        
        // Fetch data
        fetchData()
    }
    
    func retreiveCoupon() {
        // TODO: FKJ - API call that will send the `ratedContent` to backend and receive the coupon for the user.
        coupon = "111-222-333"
    }
    
}
