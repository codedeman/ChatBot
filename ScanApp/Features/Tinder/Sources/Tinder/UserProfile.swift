//
//  File.swift
//  
//
//  Created by Kevin on 6/8/24.
//

import Foundation

struct UserProfile: Identifiable, Codable {
    let id: String
    let name: String
    let age: Int
    let imageName: String
}
