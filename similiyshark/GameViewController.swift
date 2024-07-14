import UIKit
import SpriteKit

class GameViewController: UIViewController {
    @IBOutlet weak var modalView: UIView!
    @IBOutlet weak var label: UILabel!
    
    var skView: SKView?
    var gameScene: GameScene?
    @IBOutlet weak var muteButton: UIButton!
    
    var isMute = false
    
    //    cek musik player nya di mana buat nya?
        let appDelegete = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(moveToGameOver),
                                               name: NSNotification.Name("gameover"),
                                               object: nil)
        
        skView = self.view as? SKView
        
        if let view = skView {
            if let scene = SKScene(fileNamed: "GameScene") {
                scene.scaleMode = .aspectFill
                view.presentScene(scene)
                gameScene = scene as? GameScene
            }
            
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    @objc func moveToGameOver() {
        performSegue(withIdentifier: "segueToGameOver", sender: self)
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
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToGameOver" {
            if let gameOverVC = segue.destination as? GameOverViewController {
                if let scene = gameScene {
                    gameOverVC.finalScore = scene.depth // Mengirim nilai depth ke GameOverViewController
                }
            }
        }
    }
    
    func resetGame() {
        if let view = skView {
            view.presentScene(nil)  // Menghapus scene saat ini
            if let scene = SKScene(fileNamed: "GameScene") {
                scene.scaleMode = .aspectFill
                view.presentScene(scene)
                gameScene = scene as? GameScene
            }
        }
    }
    
//    @IBAction func backtohome(_ sender: Any) {
//        navigationController?.popViewController(animated: true)
//    }
    
    
    
    
    @IBAction func pause(_ sender: Any) {
        if let view = skView, let scene = view.scene as? GameScene {
            scene.isPaused = true
            label.text = "Depth: \(scene.depth)m"
            modalView.isHidden = false
        }
    }
    
    @IBAction func continueGame(_ sender: Any) {
        if let view = skView, let scene = view.scene as? GameScene {
            scene.isPaused = false
            modalView.isHidden = true
        }
    }
}
