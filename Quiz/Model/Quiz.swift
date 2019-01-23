//
//  Quiz.swift
//  Quiz
//
//  Created by Alfonso  Jiménez Martínez on 22/11/2018.
//  Copyright © 2018 Alfonso  Jiménez Martínez. All rights reserved.
//

import Foundation

/// Estructura para representar una raza de pokemon.
struct Quiz: Codable {
    let id: Int?
    let question: String?
    let author: Author?
    let attachment: Attachment?
    let favourite: Bool?
    let tips: [String]?
    
    
    struct Author: Codable {
        let id: Int?
        let isAdmin: Bool?
        let username: String?
    }
    
    struct Attachment: Codable {
        let filename: String?
        let mime: String?
        let url: String?
    }
}
