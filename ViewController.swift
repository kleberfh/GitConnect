//
//  ViewController.swift
//  GitConnect
//
//  Created by Kleber Fernando on 12/05/18.
//  Copyright © 2018 Kleber Fernando. All rights reserved.
//

import UIKit
import Foundation

import SwiftyJSON
import DGElasticPullToRefresh
import SVProgressHUD

class ViewController: UIViewController {
    
//    RECONECT ALL @IBOUTLETS
//    let tableController = GitCustomTableTableViewCell()
    
    let requestControllers = RequestController()
    
    override func viewWillAppear(_ animated: Bool) {
        SVProgressHUD.setHapticsEnabled(true)
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
    }
    
    override func viewDidLoad() {
//        self.requestController.loadData(isReload: false)
//        self.requestController.retryButton()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
}

