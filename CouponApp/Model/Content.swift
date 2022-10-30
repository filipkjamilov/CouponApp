//  Created by Filip Kjamilov on 30.10.22.

import Foundation

enum Rating: Codable {
    case unknown
    case liked
    case disliked
    case skipped
}

struct Content: Codable {
    
    var id: Int
    var name: String
    var imageURL: String
    var downloadedImage: Data
    var rating: Rating = .unknown
    
    // MARK: -
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case imageURL
        case downloadedImage
        case rating
    }
    
    init(id: Int, name: String, imageURL: String, downloadedImage: Data) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.downloadedImage = downloadedImage
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        imageURL = try values.decode(String.self, forKey: .imageURL)
        downloadedImage = try values.decode(Data.self, forKey: .downloadedImage)
        rating = try values.decode(Rating.self, forKey: .rating)
    }
    
}
