//
//  ProfileModel.swift
//  Tender
//
//  Created by Daniel Widjaja on 21/03/23.
//

import Foundation
import SwiftUI

struct ProfileModel: Identifiable, Hashable, Codable {
    var id: String?
    var name: String
    var age: Int
    var role: String
    var photoUrl: String
    var interests: [String]
}
