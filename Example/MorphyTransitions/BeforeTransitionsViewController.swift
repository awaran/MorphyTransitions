//
//  BeforeTransitionsViewController.swift
//  MorphyTransitionsTests
//
//  Created by Arjay Waran on 6/15/19.
//  Copyright © 2019 Arjay Waran. All rights reserved.
//

import UIKit
import MorphyTransitions


public class BeforeTransitionsViewController: UIViewController {

    let storyboardName = "Main"
    let afterTransVCID = "afterTransId"
    
    @IBOutlet weak var transButton: UIButton!
    
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //transistion to after view controller programically
    @IBAction func codePushPressed(_ sender: Any) {
        
        if let navController = self.navigationController as? TransNavController {
            
            let sb =  UIStoryboard(name: self.storyboardName, bundle: nil)
            
            let afterVC = sb.instantiateViewController(withIdentifier: self.afterTransVCID)

            navController.pushViewController(afterVC, animated: true)


        }
        

        
    }
    
    @IBAction func swapPressed(_ sender: Any) {
        
        do {
            try self.leftView.swapView(dest: self.rightView, animationDuration: 1.0, doesFade: true, fadeDuration: 0.5, callback: {
                print("completed")
            })
        } catch {
            print("error: caught error thrown with swap view")
        }
        
        
    }
    
    
    
    @IBAction func swapAndResetPressed(_ sender: Any) {
        do {
            
            try self.leftView.swapViewsWithReset(dest: self.rightView, animationDuration: 1.0, doesFade: true, fadeDuration: 0.5) { (resetBlock) in
                resetBlock()
                print("completed")
            }
            
        } catch {
            print("error: caught error thrown with swap and reset view")
        }

        
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
