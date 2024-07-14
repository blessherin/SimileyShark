//
//  MainMenuViewController.swift
//  similiyshark
//
//  Created by Foundation-026 on 26/06/24.
//

import UIKit
import SpriteKit
import AVFoundation

class MainMenuViewController: UIViewController {
    
    @IBOutlet weak var highscoreLabel: UILabel!
    
    @IBOutlet weak var BackgroundImageView: UIImageView!
    @IBOutlet weak var muteButton: UIButton!

    var backgroundNumber = 1
    var isMute = false

    //    cek musik player nya di mana buat nya?
        let appDelegete = UIApplication.shared.delegate as! AppDelegate
        
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    
        // Load and display the highest score
        let highScore = UserDefaults.standard.integer(forKey: "highScore")
        highscoreLabel.text = "High Score: \(highScore)"
        
        // Add observer for high score update notification
               NotificationCenter.default.addObserver(self, selector: #selector(updateHighScoreLabel(_:)), name: NSNotification.Name("HighScoreUpdated"), object: nil)
    }
   

   
    @objc func updateHighScoreLabel(_ notification: Notification) {
         if let highScore = notification.userInfo?["highScore"] as? Int {
             highscoreLabel.text = "High Score: \(highScore)"
         }
     }


      
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationItem.setHidesBackButton(true, animated: true)
        
        if appDelegete.music?.isPlaying == true {
            muteButton.setImage(UIImage(named: "sound button"), for: .normal)
        } else {
            muteButton.setImage(UIImage(named: "silent sound"), for: .normal)
        }
    }
    
    
    @IBAction func changeMuteStatus(_ sender: Any) {
        if !isMute {
            muteButton.setImage(UIImage(named: "silent sound"), for: .normal)
            isMute = true
            appDelegete.music?.stop()
            
        }else{
            muteButton.setImage(UIImage(named: "sound button"), for: .normal)
            isMute = false
            appDelegete.music?.play()
        }
    }
    

    
    @IBAction func gotogame(_ sender: Any) {
        if let gameplay = storyboard?.instantiateViewController(withIdentifier: "GameViewController") as? GameViewController {
            navigationController?.pushViewController(gameplay, animated: true)
        }
    }
    
    
    
    deinit {
        // Remove observer
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("HighScoreUpdated"), object: nil)
    }
    
}
