//
//  GitCustomTableTableViewCell.swift
//  GitConnect
//
//  Created by Kleber Fernando on 19/05/18.
//  Copyright © 2018 Kleber Fernando. All rights reserved.
//

import UIKit
import DGElasticPullToRefresh
import SVProgressHUD

class GitCustomTableTableViewCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var gitTableView:UITableView!
    @IBOutlet weak var gitCell:UIView!
    @IBOutlet weak var gitImage:UIImageView!
    @IBOutlet weak var gitRepositorie:UILabel!
    @IBOutlet weak var gitDescription:UILabel!
    @IBOutlet weak var gitUsername:UILabel!
    
    var gitApiUsername = [] as Array
    var gitApiDescription = [] as Array
    var gitApiRepositorie = [] as Array
    var gitApiImages = [] as Array
    
    public func passData(usernames: Array<Any>, repositories: Array<Any>, descriptions: Array<Any>, imagesUrl: Array<Any>) {
        self.gitApiUsername = usernames
        self.gitApiRepositorie = repositories
        self.gitApiDescription = descriptions
        self.gitApiImages = imagesUrl
    }
    
    public func clearData() {
        self.gitApiUsername.removeAll()
        self.gitApiDescription.removeAll()
        self.gitApiRepositorie.removeAll()
        self.gitApiImages.removeAll()
    }
    
    private func reloadTableData() {
        self.gitTableView?.delegate = self
        self.gitTableView?.dataSource = self
        self.gitTableView.reloadData()
    }
    
    func reloadTable() {
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
        gitTableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self?.requestController.loadData(isReload: true)
            self?.reloadTable()
            self?.gitTableView.dg_stopLoading()
            }, loadingView: loadingView)
        gitTableView.dg_setPullToRefreshFillColor(UIColor(red: 43/255.0, green: 43/255.0, blue: 43/255.0, alpha: 1.0))
        gitTableView.dg_setPullToRefreshBackgroundColor(gitTableView.backgroundColor!)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gitApiRepositorie.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 165
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            let gitCell = gitTableView?.dequeueReusableCell(withIdentifier: "gitCell") as! GitCustomTableTableViewCell;
            
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
            if (self.requestController.page <= 33) {
                self.requestController.page = self.requestController.page + 1
                self.requestController.loadData(isReload: false)
            } else {
                SVProgressHUD.dismiss(withDelay: 0.45)
                SVProgressHUD.showInfo(withStatus: "Fim dos dados.")
            }
        }
    }
}
