//
//  RandomPlayViewController.swift
//  Quiz
//
//  Created by Celia Falcón Lozano on 24/11/2018.
//  Copyright © 2018 Alfonso  Jiménez Martínez. All rights reserved.
//

import UIKit

class RandomPlayViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var questionTag: UILabel!
    @IBOutlet weak var answerTag: UITextField!
    @IBOutlet weak var imageView: UIImageView!
     @IBOutlet weak var scoreTag: UILabel!
    
    @IBOutlet weak var feedBackImage: UIImageView!
    fileprivate let token = "token=17f7c4049dc98483ec00"
    fileprivate let baseUrl = "https://quiz2019.herokuapp.com/api/quizzes/"
    
    fileprivate struct CheckedAnswerJson: Codable {
        let quizId: Int?
        let answer: String?
        let result: Bool?
    }
    
    fileprivate struct ResponseObject: Codable {
        let quiz: Quiz?
        var score: Int?
    }
    
    var imageCache = [String:UIImage]()
    
    var answer: String = ""
    
    var quiz: Quiz?
    
    var quizImage: UIImage?
    
    var score: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadQuiz("new")
        
        self.feedBackImage.image = UIImage(named: "Question")
        
    }
    
    private func loadQuiz(_ next:String) {
        var randomUrl = self.baseUrl + "randomPlay/" + next + "?" + token
        if let url = URL(string: randomUrl) {
            let queue = DispatchQueue(label: "Download Queue")
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
                        let responseObject = try decoder.decode(ResponseObject.self, from: data)
                        
                        DispatchQueue.main.async {
                            
                            if(responseObject.score! < 10) {
                                
                                self.quiz = responseObject.quiz!
                                self.setImage(self.quiz?.attachment?.url)
                                self.answerTag.delegate = self
                                
                                self.questionTag.text = (self.quiz?.question ?? "") + "?"
                                
                            } else{
                                return
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    private func setImage(_ url: String?) {
        if let validUrl = url {
            if(self.imageCache[validUrl] != nil) {
                self.quizImage = self.imageCache[validUrl]
            } else {
                if let imgUrl = URL(string: url ?? "https://quiz2019.herokuapp.com/images/none.png") {
                    let queue = DispatchQueue(label: "Download Queue")
                    queue.async {
                        DispatchQueue.main.async {
                            UIApplication.shared.isNetworkActivityIndicatorVisible = true
                        }
                        defer {
                            DispatchQueue.main.async {
                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            }
                        }
                        if let data = try? Data(contentsOf: imgUrl),
                            let img = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self.quizImage = img
                                self.imageCache[url  ?? "https://quiz2019.herokuapp.com/images/none.png"] = img
                                self.imageView.image = img
                            }
                        }
                    }
                } else {
                    print("undefined URL")
                }
            }
        } else {
            self.quizImage = self.imageCache["https://quiz2019.herokuapp.com/images/none.png"]
            print("undefined URL")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        answer = answerTag.text ?? ""
        checkAnswer(submittedText: answer)
        return true
    }
    
    @IBAction func submitAnswer(_ sender: UIButton) {
        answer = answerTag.text ?? ""
        checkAnswer(submittedText: answer)
    }
    @IBAction func tryAgain(_ sender: UIButton) {
        self.loadQuiz("next")
        self.answerTag.text = ""
        self.viewDidLoad()
    }
    
   
    
    private func checkAnswer(submittedText: String){
        if let escapedAnswer = submittedText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
        
        let compoundUrl = baseUrl + String(self.quiz?.id ?? 0) + "/check?answer=" + escapedAnswer + "&" + token
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
                                self.feedBackImage.image = UIImage(named: "Correct")
                                self.score = self.score + 1
                                self.scoreTag.text = "SCORE: " + String(self.score)
    
                            } else {
                                self.feedBackImage.image = UIImage(named: "Incorrect")
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
