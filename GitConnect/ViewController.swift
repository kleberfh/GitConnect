//
//  ViewController.swift
//  GitConnect
//
//  Created by Kleber Fernando on 12/05/18.
//  Copyright © 2018 Kleber Fernando. All rights reserved.
//

import UIKit
import Foundation

import Alamofire
import SwiftyJSON
import DGElasticPullToRefresh
import SVProgressHUD

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    @IBOutlet weak var dataTableView: UITableView!
    @IBOutlet weak var blurEffect: UIVisualEffectView!
    
    var gitApiUsername = [] as Array
    var gitApiDescription = [] as Array
    var gitApiRepositorie = [] as Array
    var gitApiImages = [] as Array
    
    let apiUrl = "https://api.github.com/search/repositories?q=language:Swift&sort=stars&page="
    
    var page = 1
    
    let alert = UIAlertController(title: "Sem conexão", message: "Este app precisa de internet e parece que você não está conectado. Deseja tentar se conectar novamente?", preferredStyle: .alert)
    
    override func viewWillAppear(_ animated: Bool) {
        SVProgressHUD.setHapticsEnabled(true)
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
    }
    
    override func viewDidLoad() {
        self.retryButton()
        self.loadData(isReload: false)
        self.reloadTable()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    public func clearData() {
        self.gitApiUsername.removeAll()
        self.gitApiDescription.removeAll()
        self.gitApiRepositorie.removeAll()
        self.gitApiImages.removeAll()
        self.page = 1
        
        self.loadData(isReload: true)
        
        self.reloadTableData()
    }
    
    public func reloadTableData() {
        dataTableView?.delegate = (self as UITableViewDelegate)
        dataTableView?.dataSource = (self as UITableViewDataSource)
        dataTableView?.reloadData()
    }
    
    public func reloadTable() {
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
        self.dataTableView?.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self?.blurEffect.isHidden = false
            self?.clearData()
            self?.dataTableView?.dg_stopLoading()
            }, loadingView: loadingView)
        self.dataTableView?.dg_setPullToRefreshFillColor(UIColor(red: 43/255.0, green: 43/255.0, blue: 43/255.0, alpha: 1.0))
        self.dataTableView?.dg_setPullToRefreshBackgroundColor((self.dataTableView?.backgroundColor!)!)
    }
    
    public func retryButton() {
        let retryAction = UIAlertAction(title: "Reconectar", style: .default) { (alert: UIAlertAction!) -> Void in
            self.loadData(isReload: false)
        }
        self.alert.addAction(retryAction)
    }
    
    public func loadData(isReload: Bool) {
        SVProgressHUD.show(withStatus: "Carregando dados...")
        Alamofire.request("\(self.apiUrl)\(self.page)").responseJSON { (response:DataResponse<Any>) in
            switch(response.result) {
            case .success(_):
                let jsonItems = JSON(response.result.value!)["items"].array
                if ((jsonItems == nil)||(jsonItems?.isEmpty)!) {
                    SVProgressHUD.showError(withStatus: "Erro. Aguarde um minuto e tente novamente")
                } else {
                    for item in (jsonItems!) {
                        let owner = item["owner"]
                        
                        self.gitApiUsername.append((owner["login"].string) ?? "Loading")
                        self.gitApiRepositorie.append((item["name"].string) ?? "Loading")
                        self.gitApiDescription.append((item["description"].string) ?? "Loading")
                        self.gitApiImages.append((owner["avatar_url"].string) ?? "Default")
                    }
                    self.reloadTableData()
                    self.blurEffect.isHidden = true
                }
                break
            case .failure(_):
                self.present(self.alert, animated: true, completion:nil)
                break
            }
            SVProgressHUD.dismiss()
        }
    }
    
    public func reloadData() {
        self.page = 1
        self.loadData(isReload: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.gitApiRepositorie.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 165
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            let gitCell = tableView.dequeueReusableCell(withIdentifier: "gitCell") as! CellController;
            
            gitCell.gitUsername.text = (self.gitApiUsername[indexPath.row] as! String)
            gitCell.gitDescription.text = (self.gitApiDescription[indexPath.row] as! String)
            gitCell.gitRepositorie.text = (self.gitApiRepositorie[indexPath.row] as! String)
            
            gitCell.gitImage.sd_setImage(with: URL(string: self.gitApiImages[indexPath.row] as! String), placeholderImage: UIImage(named: "Default"), options: [.continueInBackground, .delayPlaceholder])
            
            gitCell.gitImage.layer.cornerRadius = gitCell.gitImage.frame.height / 2;
            return gitCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastItem = self.gitApiRepositorie.count - 1
        if indexPath.row == lastItem {
            if (self.page <= 33) {
                self.page = self.page + 1
                self.loadData(isReload: false)
            } else {
                SVProgressHUD.dismiss(withDelay: 0.45)
                SVProgressHUD.showInfo(withStatus: "Fim dos dados.")
            }
        }
    }
}

