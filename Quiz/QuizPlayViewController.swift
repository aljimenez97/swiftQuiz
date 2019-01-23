//
//  QuizPlayViewController.swift
//  Quiz
//
//  Created by Alfonso  Jiménez Martínez on 22/11/2018.
//  Copyright © 2018 Alfonso  Jiménez Martínez. All rights reserved.
//

import UIKit



class QuizPlayViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var playTitle: UILabel!
    @IBOutlet weak var playAnswer: UITextField!
    @IBOutlet weak var playImage: UIImageView!
    @IBOutlet weak var playSubmit: UIButton!
    
    @IBOutlet weak var feedbackImage: UIImageView!
    fileprivate let token = "&token=17f7c4049dc98483ec00"
    fileprivate let baseUrl = "https://quiz2019.herokuapp.com/api/quizzes/"
    
    fileprivate struct CheckedAnswerJson: Codable {
        let quizId: Int?
        let answer: String?
        let result: Bool?
    }
    
    var answer: String = ""
    
    var quiz: Quiz?
    
    var quizImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.feedbackImage.image = UIImage(named: "Question")

        
        playAnswer.delegate = self
        
        playTitle.text = (quiz?.question ?? "") + "?"
        playImage.image = quizImage
    
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        answer = playAnswer.text ?? ""
        checkAnswer(submittedText: answer)
        return true
    }
    
    @IBAction func submitAnswer(_ sender: UIButton) {
        answer = playAnswer.text ?? ""
        checkAnswer(submittedText: answer)
    }
    
    private func checkAnswer(submittedText: String){
        if let escapedAnswer = submittedText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
        let compoundUrl = baseUrl + String(quiz?.id ?? 0) + "/check?answer=" + escapedAnswer + token
        
        if let url = URL(string: compoundUrl) {
            let queue = DispatchQueue(label: "Check Queue")
            queue.async {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                }
                defer {
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                }
                
                if let data = try? Data(contentsOf: url, options: .alwaysMapped) {
                    let decoder = JSONDecoder()
                    
                    do {
                        let responseObject = try decoder.decode(CheckedAnswerJson.self, from: data)
                        
                        DispatchQueue.main.async {
                            
                            if (responseObject.result!) {
                                self.feedbackImage.image = UIImage(named: "Correct")
                            } else {
                                self.feedbackImage.image = UIImage(named: "Incorrect")
                            }
                        }
                        
                    } catch {
                        print(error)
                    }
                }
                
                
            }
        }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Hint Segue"{
            
            let rtvc = segue.destination as? HintTableTableViewController
            
            rtvc?.hints = quiz?.tips
        
        }
    }

}

