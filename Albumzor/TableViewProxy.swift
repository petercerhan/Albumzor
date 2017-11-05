//
//  TableViewProxy.swift
//  Albumzor
//
//  Created by Peter Cerhan on 11/5/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit
import RxSwift

struct TableCellData {
    var title: String
    var subTitle: String
    var imageStream: Observable<UIImage>?
}

class TableViewProxy: NSObject, UITableViewDataSource {
    
    //MARK: - Dependencies
    
    private let tableView: UITableView
    
    
    //image cache (?)
    //[TableCellData]
    private var tableViewData = [TableCellData]()
    
    //MARK: - Initialization
    
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        tableView.dataSource = self
    }
    
    //Interface
    //RefreshTableCellDataArray
    func setTableViewData(_ tableViewData: [TableCellData]) {
        print("Set table view data with \(tableViewData.count)")
        self.tableViewData = tableViewData
        tableView.reloadData()
    }
    
    //TableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumTableViewCell") as! AlbumTableViewCell
        cell.nameLabel.text = tableViewData[indexPath.row].title
        cell.artistLabel.text = tableViewData[indexPath.row].title
        cell.albumImageView.image = nil
        
        //Set up image
        
        cell.albumImageView.layer.borderColor = UIColor.lightGray.cgColor
        cell.albumImageView.layer.borderWidth = 0.5
        cell.selectionStyle = .none
        
        return cell
    }
    
}
