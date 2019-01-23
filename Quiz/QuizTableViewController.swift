//
//  ViewController.swift
//  Quiz
//
//  Created by Alfonso  Jiménez Martínez on 18/11/2018.
//  Copyright © 2018 Alfonso  Jiménez Martínez. All rights reserved.
//

import UIKit
import WebKit

class QuizTableViewController: UITableViewController {
    
    
    fileprivate struct ResponseObject: Codable {
        let quizzes: [Quiz]?
        let pageno: Int
        let nextUrl: URL
    }

    fileprivate let token = "17f7c4049dc98483ec00"
    
    let quizzesUrl = "https://quiz2019.herokuapp.com/api/quizzes?token="
    
    fileprivate var quizzes: [Quiz] = []
    
    var imageCache = [String:UIImage]()
    var quizzesQuestions: [String] = []
    var favs = [String:Bool]()
    var nextPage: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        
        if let favsDefault = defaults.object(forKey: "favs") as? [String:Bool]{
            favs = favsDefault
        }
        
        loadQuizzes(1)
        loadDefaultImage("https://quiz2019.herokuapp.com/images/none.png")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    private func loadQuizzes(_ numPag:Int) {
        var myUrl = self.quizzesUrl + token + "&pageno=" + String(numPag)
        if let url = URL(string: myUrl) {
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
                            if(responseObject.quizzes?.count != 0) {
                                let filteredQuizzes = self.deleteDuplicatesByQuestion(responseObject.quizzes!)
                                self.quizzes.append(contentsOf: filteredQuizzes)
                                self.tableView.reloadData()
                                self.loadQuizzes(Int(responseObject.pageno) + 1)
                            } else{
                                self.tableView.reloadData()
                                return
                            }
                        }
                    } catch {
                        print(error)
                    }
                } else {
                    let alert = UIAlertController(title: "No internet conection", message: "Quizzes could not be downloaded. Please try again when connection is reestablished", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    private func loadDefaultImage(_ urlString: String){
        if let url = URL(string: urlString){
            if let data = try? Data(contentsOf: url),
                let img = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.imageCache[urlString] = img
                }
            }
        }
        
    }
    
    private func loadAttributes(_ url: String?, _ cell: QuizTableViewCell, _ quizId: String) {
        if let validUrl = url {
            if(self.imageCache[validUrl] != nil) {
                cell.quizImage.image = self.imageCache[validUrl]
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
                                cell.quizImage.image = img
                                self.imageCache[url  ?? "https://quiz2019.herokuapp.com/images/none.png"] = img
                                self.favs[quizId] = self.favs[quizId] ?? false

                            }
                        }
                    }
                } else {
                    print("undefined URL")
                }
        }
        } else {
            cell.quizImage.image = self.imageCache["https://quiz2019.herokuapp.com/images/none.png"]
            print("undefined URL")
        }
    }
    
    private func deleteDuplicatesByQuestion (_ quizzes: [Quiz]) -> [Quiz] {
        var filteredQuizzes:[Quiz] = []
        for quiz in quizzes {
            if let quest = quiz.question {
                if quizzesQuestions.contains(quest){
                    
                } else {
                    quizzesQuestions.append(quest)
                    filteredQuizzes.append(quiz)
                }
            } else {
                print("could not find the question for the quiz")
            }
        }
        return filteredQuizzes
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quizzes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Quiz Cell", for: indexPath) as! QuizTableViewCell
        let quiz = quizzes[indexPath.row]
        let quizId = String(quiz.id!)
    
        cell.quizQuestion.text = quiz.question
        cell.quizAuthor.text = "by: \(quiz.author?.username ?? "unknown")"
        
        if (favs[quizId] ?? false){
            cell.quizFav.setBackgroundImage(UIImage(named: "Fav"), for: .normal)

        } else {
            cell.quizFav.setBackgroundImage(UIImage(named: "NotFav"), for: .normal)

        }
        cell.quizFav.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
    
        loadAttributes(quiz.attachment?.url, cell, quizId)
        
        return cell
    }
    
    @objc private func didTapButton(_ sender: UIButton) {
        if let superview = sender.superview, let cell = superview.superview as? QuizTableViewCell {
            if let indexPath = tableView.indexPath(for: cell) {
                sender.setTitle("", for: .normal)
                let quizQuestion = String(quizzes[indexPath.row].id!)
                let fav = favs[quizQuestion] ?? false
                if (fav) {
                    cell.quizFav.setBackgroundImage(UIImage(named: "NotFav"), for: .normal)
                    addOrRemoveFav(quizzes[indexPath.row].id ?? 0, add: false, imageButton: cell.quizFav, idFav: quizQuestion)
                } else {
                    cell.quizFav.setBackgroundImage(UIImage(named: "Fav"), for: .normal)
                    addOrRemoveFav(quizzes[indexPath.row].id ?? 0, add: true, imageButton: cell.quizFav, idFav: quizQuestion)
                }
            }
        }
    }
    
    private func addOrRemoveFav(_ id: Int, add: Bool, imageButton: UIButton, idFav: String) {
        let defaults = UserDefaults.standard
        var method = "PUT"
        if (!add){
            method = "DELETE"
        }
        let urlString = "https://quiz2019.herokuapp.com/api/users/tokenOwner/favourites/\(String(id))?token=\(token)"
        if let url = URL(string: urlString) {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = method
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: urlRequest) {
                (data, response, error) in
                guard let response = response else {
                    let alert = UIAlertController(title: "No internet conection", message: "Transaction could not be performed. Please try again when connection is reestablished", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    
                    if(add){
                        DispatchQueue.main.async {
                            imageButton.setBackgroundImage(UIImage(named: "NotFav"), for: .normal)
                            self.favs[idFav] = false
                            defaults.set(self.favs, forKey: "favs")
                            defaults.synchronize()
                        }
                    } else {
                        DispatchQueue.main.async {
                            imageButton.setBackgroundImage(UIImage(named: "Fav"), for: .normal)
                            self.favs[idFav] = true
                            defaults.set(self.favs, forKey: "favs")
                            defaults.synchronize()
                        }
                    }
                    print("error calling DELETE on /todos/1")
                    return
                }
                if let res = response as? HTTPURLResponse {
                    if (res.statusCode == 200){
                        if(add){
                            DispatchQueue.main.async {
                                imageButton.setBackgroundImage(UIImage(named: "Fav"), for: .normal)
                                self.favs[idFav] = true
                                defaults.set(self.favs, forKey: "favs")
                                defaults.synchronize()
                            }
                        } else {
                            DispatchQueue.main.async {
                            imageButton.setBackgroundImage(UIImage(named: "NotFav"), for: .normal)
                                self.favs[idFav] = false
                                defaults.set(self.favs, forKey: "favs")
                                defaults.synchronize()
                            }
                        }
                    } else {
                        print("Error performing request")
                    }
                } else {
                    
                }
            }
            task.resume()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Play Segue"{
            let rtvc = segue.destination as? QuizPlayViewController
            if let index = tableView.indexPathForSelectedRow {
                rtvc?.quiz = quizzes[index.row]
                rtvc?.quizImage =  imageCache[(quizzes[index.row].attachment?.url) ?? "https://quiz2019.herokuapp.com/images/none.png"]
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(favs, forKey: "favs")
        defaults.synchronize()
    }
    
}

