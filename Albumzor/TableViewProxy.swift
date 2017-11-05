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
    var imageData: Data?
    var imageStream: Observable<UIImage>?
}

class TableViewProxy: NSObject, UITableViewDataSource {
    
    //MARK: - Dependencies
    
    private let tableView: UITableView
    
    //image cache (?)
    //[TableCellData]
    private var tableViewData = [TableCellData]()
    
    //MARK: - Rx
    
    private let disposeBag = DisposeBag()
    
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
        let cellData = tableViewData[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumTableViewCell") as! AlbumTableViewCell
        cell.nameLabel.text = cellData.title
        cell.artistLabel.text = cellData.title
        cell.albumImageView.image = nil
        
        //Set up image
        if let imageData = cellData.imageData {
            cell.albumImageView.image = UIImage(data: imageData)
        } else {
            print("Get image")
            if let imageStream = cellData.imageStream {
                imageStream
                    .observeOn(MainScheduler.instance)
                    .subscribe(onNext: { [unowned self] image in
                        print("Got image")
                        cell.albumImageView.image = image
                        
                        //set data in table data
                        self.tableViewData[indexPath.row].imageData = UIImagePNGRepresentation(image)
                        
                        //persist
                        //persist in do() earlier in the channel
                        
                    })
                    .disposed(by: disposeBag)
            }
        }
        
        
        
        
        cell.albumImageView.layer.borderColor = UIColor.lightGray.cgColor
        cell.albumImageView.layer.borderWidth = 0.5
        cell.selectionStyle = .none
        
        return cell
    }
    
}




















