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
    var id: String
    var imageData: Data?
    var imageStream: Observable<UIImage>?
}

class TableViewProxy: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: - Dependencies
    
    private let tableView: UITableView
    
    //MARK: - State
    
    private(set) lazy var albumDetailsID: Observable<String> = {
        return self.albumDetailsIDSubject.asObservable().share()
    }()
    
    private let albumDetailsIDSubject = PublishSubject<String>()
    
    private(set) lazy var editingActive: Observable<Bool> = {
        return self.editingActiveSubject.asObservable().shareReplay(1)
    }()
    
    private let editingActiveSubject = BehaviorSubject<Bool>(value: false)
    
    private(set) lazy var deleteAlbumID: Observable<String> = {
        return self.deleteAlbumIDSubject.asObservable().share()
    }()
    
    private let deleteAlbumIDSubject = PublishSubject<String>()
    
    
    
    
    private var tableViewData = [TableCellData]()
    //image cache (?)
    
    //MARK: - Rx
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Initialization
    
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    //MARK: - Interface
    
    //RefreshTableCellDataArray
    func setTableViewData(_ tableViewData: [TableCellData]) {
        self.tableViewData = tableViewData
        tableView.reloadData()
    }
    
    //MARK: - TableViewDataSource
    
    //TableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = tableViewData[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumTableViewCell") as! AlbumTableViewCell
        cell.nameLabel.text = cellData.title
        cell.artistLabel.text = cellData.subTitle
        cell.albumImageView.image = nil
        
        //Set up image
        if let imageData = cellData.imageData {
            cell.albumImageView.image = UIImage(data: imageData)
        } else {
            if let imageStream = cellData.imageStream {
                imageStream
                    .observeOn(MainScheduler.instance)
                    .subscribe(onNext: { [unowned self] image in
                        cell.albumImageView.image = image
                        self.tableViewData[indexPath.row].imageData = UIImagePNGRepresentation(image)
                    })
                    .disposed(by: disposeBag)
            }
        }
        
        cell.albumImageView.layer.borderColor = UIColor.lightGray.cgColor
        cell.albumImageView.layer.borderWidth = 0.5
        cell.selectionStyle = .none
        
        return cell
    }
    
    //MARK: - TableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        albumDetailsIDSubject.onNext(tableViewData[indexPath.row].id)
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        editingActiveSubject.onNext(true)
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        editingActiveSubject.onNext(false)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let albumData = tableViewData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            deleteAlbumIDSubject.onNext(albumData.id)
        }
    }
    
    
}





















