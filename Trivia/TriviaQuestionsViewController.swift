//
//  TriviaQuestionsViewController.swift
//  Trivia
//
//  Created by Lucy Lu on 10/6/23.
//

import UIKit

// Model
struct Question: Codable {
    let category: String
    let questionText: String
    let answers: [String]
    let correctAnswerIndex: Int
}

class TriviaGame {
    private(set) var questions: [Question]
    private(set) var currentQuestionIndex: Int = 0
    private(set) var score: Int = 0
    
    init(questions: [Question]) {
        self.questions = questions
    }
    
    func answerQuestion(withIndex index: Int) -> Bool {
        let correct = questions[currentQuestionIndex].correctAnswerIndex == index
        if correct {
            score += 1
        }
        currentQuestionIndex += 1
        return correct
    }
    
  
    
    func isGameOver() -> Bool {
        return currentQuestionIndex >= questions.count
    }
    
    func restart() {
        currentQuestionIndex = 0
        score = 0
    }
    
    
}

extension TriviaGame {
    class func loadQuestions(from filename: String, withExtension fileExtension: String = "json") -> [Question]? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: fileExtension) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let questions = try JSONDecoder().decode([Question].self, from: data)
            return questions
        } catch {
            print("Error loading and decoding JSON: \(error)")
            return nil
        }
    }
}


class TriviaQuestionsViewController: UIViewController {
    
    @IBOutlet weak var QuestionAnswered: UILabel!
    @IBOutlet weak var QuestionCategory: UILabel!
    @IBOutlet weak var QuestionLabel: UILabel!
    
    @IBOutlet weak var Answer1Button: UIButton!
    @IBOutlet weak var Answer2Button: UIButton!
    @IBOutlet weak var Answer3Button: UIButton!
    @IBOutlet weak var Answer4Button: UIButton!
    
    @IBAction func answerButtonTapped(_ sender: UIButton) {
        guard let answerIndex = [Answer1Button, Answer2Button, Answer3Button, Answer4Button].firstIndex(of: sender) else {
            return
        }
        
        if game.answerQuestion(withIndex: answerIndex) {
            // Handle correct answer (perhaps change button color momentarily)
        } else {
            // Handle incorrect answer
        }
        
        // Delay for a brief moment to let the user see feedback, then load the next question
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.displayCurrentQuestion()
        }
    }

    
    
    private var currentQuestionNumber: Int = 1
    private let totalQuestions: Int = 6
    var toastLabel: UILabel?
    var toastCompletion: (() -> Void)?

    
    private func updateQuestionNumberLabel() {
        QuestionAnswered.text = "Question: \(currentQuestionNumber)/\(totalQuestions)"
    }
    
    // Within TriviaQuestionsViewController
    private var game: TriviaGame!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateQuestionNumberLabel()
        
        if let loadedQuestions = TriviaGame.loadQuestions(from: "questions") {
            game = TriviaGame(questions: loadedQuestions)
            displayCurrentQuestion()
        }
    
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         }
         */
        
    }
    
    
    func displayCurrentQuestion() {
        
            // Handle game over
        currentQuestionNumber = game.currentQuestionIndex + 1
        if game.currentQuestionIndex >= game.questions.count {
            let message = """
            Game over.
            Final score: \(game.score)/\(game.questions.count).
            Tap 'Restart' to play again.
            """
            showToast(message: message) {
                self.restartGame()
            }
            return
        }

     
        currentQuestionNumber = game.currentQuestionIndex + 1
        let currentQuestion = game.questions[game.currentQuestionIndex]
        
        QuestionCategory.text = currentQuestion.category
        QuestionLabel.text = currentQuestion.questionText
        
        Answer1Button.setTitle(currentQuestion.answers[0], for: .normal)
        Answer2Button.setTitle(currentQuestion.answers[1], for: .normal)
        Answer3Button.setTitle(currentQuestion.answers[2], for: .normal)
        Answer4Button.setTitle(currentQuestion.answers[3], for: .normal)
        
        updateQuestionNumberLabel()
        
        
    }
    
    func advanceToNextQuestion() {
        // Make sure we're not already on the last question
        if currentQuestionNumber < totalQuestions {
            currentQuestionNumber += 1
            updateQuestionNumberLabel()
            
            // Load the new question and answers here...
        }
    }
    
  

    func showToast(message: String, completion: @escaping () -> Void) {
        toastLabel?.removeFromSuperview()  // Ensure we only have one toast at a time

        toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 150, y: self.view.frame.size.height-100, width: 300, height: 70))
        toastLabel!.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel!.textColor = UIColor.white
        toastLabel!.textAlignment = .center
        toastLabel!.text = message
        toastLabel!.alpha = 1.0
        toastLabel!.layer.cornerRadius = 10
        toastLabel!.numberOfLines = 0
        toastLabel!.clipsToBounds = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleToastTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        toastLabel!.isUserInteractionEnabled = true
        toastLabel!.addGestureRecognizer(tapGesture)

        self.view.addSubview(toastLabel!)
        self.toastCompletion = completion
    }

    @objc func handleToastTapped(_ sender: UITapGestureRecognizer) {
        toastLabel?.removeFromSuperview()
        toastCompletion?()
    }

    
    func restartGame() {
        game.restart()
        currentQuestionNumber = 1
        displayCurrentQuestion()
        updateQuestionNumberLabel()
    }

    
}
