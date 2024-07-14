//  storyViewController.swift
//  similiyshark
//
//  Created by Foundation-026 on 27/06/24.
//

import UIKit

class storyViewController: UIViewController {
    
    @IBOutlet weak var BackgroundImageview: UIImageView!
    var isMute = true

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.music?.stop()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.music?.play()
    }
    
    @IBAction func backtosetting(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func skiptomenu(_ sender: Any) {
        if let gameplay = storyboard?.instantiateViewController(withIdentifier: "MainMenuViewController") as? MainMenuViewController {
            navigationController?.pushViewController(gameplay, animated: true)
        }
    }
}
