//
//  RequestController.swift
//  GitConnect
//
//  Created by Kleber Fernando on 29/05/18.
//  Copyright © 2018 Kleber Fernando. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD

class RequestController: UIViewController {
    
    let apiUrl = "https://api.github.com/search/repositories?q=language:Swift&sort=stars&page="
    
    var page = 1
    
    let mainController = ViewController()
    let tableController = GitCustomTableTableViewCell()
    
    let alert = UIAlertController(title: "Sem conexão", message: "Este app precisa de internet e parece que você não está conectado. Deseja tentar se conectar novamente?", preferredStyle: .alert)
    
    public func loadData(isReload: Bool) {
        if isReload == false {
            SVProgressHUD.show(withStatus: "Carregando dados...")
        }
        Alamofire.request("\(self.apiUrl)\(self.page)").responseJSON { (response:DataResponse<Any>) in
            switch(response.result) {
            case .success(_):
                let jsonItems = JSON(response.result.value!)["items"].array
                if ((jsonItems == nil)||(jsonItems?.isEmpty)!) {
                    SVProgressHUD.showError(withStatus: "Erro. Aguarde um minuto e tente novamente")
                } else {
                    var gitApiUsername = [] as Array
                    var gitApiDescription = [] as Array
                    var gitApiRepositorie = [] as Array
                    var gitApiImages = [] as Array
                    
                    for item in (jsonItems!) {
                        let owner = item["owner"]
                        
                        gitApiUsername.append((owner["login"].string) ?? "Loading")
                        gitApiRepositorie.append((item["name"].string) ?? "Loading")
                        gitApiDescription.append((item["description"].string) ?? "Loading")
                        gitApiImages.append((owner["avatar_url"].string) ?? "Default")
                    }
                    
                    self.tableController.passData(usernames: gitApiUsername, repositories: gitApiRepositorie, descriptions: gitApiDescription, imagesUrl: gitApiImages)
                    SVProgressHUD.dismiss()
                }
                break
            case .failure(_):
                self.present(self.alert, animated: true, completion:nil)
                break
                
            }
        }
    }
    
    public func reloadData() {
        self.page = 1
        self.loadData(isReload: true)
    }
    
    public func retryButton() {
        let retryAction = UIAlertAction(title: "Reconectar", style: .default) { (alert: UIAlertAction!) -> Void in
            self.loadData(isReload: false)
        }
        self.alert.addAction(retryAction)
    }

}
