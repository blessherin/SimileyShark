import UIKit

class GameOverViewController: UIViewController {
    
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    var finalScore: Int = 0  // Properti untuk menerima nilai kedalaman
    var countdownTimer: Timer?
    var countdownValue: Int = 5  // Waktu hitung mundur dalam detik

    @IBOutlet weak var monster: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Menampilkan finalScore di label
        scoreLabel.text = "Depth: \(finalScore)m"
        
        // Update label to say "Tap to Restart"
               countdownLabel.text = "Tap to Restart"
                
        // Add tap gesture recognizer to the countdown label
             let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(restartGame))
             countdownLabel.isUserInteractionEnabled = true
             countdownLabel.addGestureRecognizer(tapGestureRecognizer)
        
       
        // Start blinking animation
              startBlinking()
        // Save the high score
          saveHighScore()
        // Start the monster animation
               startMonsterAnimation()
        
    }
    func saveHighScore() {
           let defaults = UserDefaults.standard
           let currentHighScore = defaults.integer(forKey: "highScore")
           if finalScore > currentHighScore {
               defaults.set(finalScore, forKey: "highScore")
               // Post a notification for the high score update
               NotificationCenter.default.post(name: NSNotification.Name("HighScoreUpdated"), object: nil, userInfo: ["highScore": finalScore])
           }
       }
    @objc func restartGame() {
          if let viewControllers = self.navigationController?.viewControllers {
              for viewController in viewControllers {
                  if let gameViewController = viewController as? GameViewController {
                      gameViewController.resetGame()
                      self.navigationController?.popToViewController(gameViewController, animated: true)
                      return
                  }
              }
          }
        
        // Jika GameViewController tidak ditemukan, buat instance baru
        if let gameViewController = storyboard?.instantiateViewController(withIdentifier: "GameViewController") as? GameViewController {
            self.navigationController?.setViewControllers([gameViewController], animated: true)
        }
    }

//    @IBAction func home(_ sender: Any) {
//        // Navigasi ke MainMenuViewController
//             if let mainMenuViewController = storyboard?.instantiateViewController(withIdentifier: "MainMenuViewController") as? MainMenuViewController {
//                 self.navigationController?.setViewControllers([mainMenuViewController], animated: true)
//             }
//    }
    
    
    // Function to start blinking animation
        func startBlinking() {
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = 1.0
            animation.toValue = 0.0
            animation.duration = 0.5
            animation.repeatCount = .infinity
            animation.autoreverses = true
            countdownLabel.layer.add(animation, forKey: "blinkAnimation")
        }

    // Function to start monster animation
       func startMonsterAnimation() {
           let originalPosition = monster.center
           let offset: CGFloat = 150.0
           
           UIView.animate(withDuration: 1.0, delay: 0.0, options: [.repeat, .autoreverse, .curveEaseInOut], animations: {
               self.monster.center = CGPoint(x: originalPosition.x + offset, y: originalPosition.y)
           }, completion: nil)
       }
    
}
