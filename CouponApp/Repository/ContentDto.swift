//  Created by Filip Kjamilov on 30.10.22.

import Foundation

struct ContentDto: Codable {
    
    var id: Int
    var name: String
    var imageName: String
    
    // MARK: -
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case imageName
    }
    
    init(id: Int, name: String, imageName: String) {
        self.id = id
        self.name = name
        self.imageName = imageName
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        imageName = try values.decode(String.self, forKey: .imageName)
    }
    
}
