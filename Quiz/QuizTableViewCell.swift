//
//  QuizTableViewCell.swift
//  Quiz
//
//  Created by Alfonso  Jiménez Martínez on 18/11/2018.
//  Copyright © 2018 Alfonso  Jiménez Martínez. All rights reserved.
//

import UIKit

class QuizTableViewCell: UITableViewCell {
    var fav:Bool = false
    @IBOutlet weak var quizQuestion: UILabel!
    @IBOutlet weak var quizAuthor: UILabel!
    @IBOutlet weak var quizImage: UIImageView!
    @IBAction func favClick(_ sender: UIButton) {
       
    }
    @IBOutlet weak var quizFav: UIButton!
    
    
}
