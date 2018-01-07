//
//  ViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/12/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit
import CoreData
import RxSwift

class HomeViewController: UIViewController {
    
    //MARK: - Dependencies
    
    fileprivate var viewModel: HomeViewModel!
    
    //MARK: - Interface Components
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var findAlbumsButton: AnimatedButton!
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var menuButton: UIBarButtonItem!
    
    var tableViewProxy: TableViewProxy!
    
    //MARK: - Rx
    
    let disposeBag = DisposeBag()
    
    //MARK: - Initialization
    
    static func createWith(storyBoard: UIStoryboard, viewModel: HomeViewModel) -> HomeViewController {
        let vc = storyBoard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        vc.viewModel = viewModel
        return vc
    }
    
    //MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        findAlbumsButton.backgroundColor = Styles.themeBlue
        menuButton.imageInsets = UIEdgeInsetsMake(7.0, 2.0, 7.0, 2.0)
        
        findAlbumsButton.baseColor = Styles.themeBlue
        findAlbumsButton.highlightedColor = Styles.shadedThemeBlue
        
        setUpTableView()
        bindActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    private func bindActions() {
        findAlbumsButton.rx.tap
            .throttle(1.0, latest: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in
                self.viewModel.dispatch(action: .requestSuggestAlbumsScene)
            })
            .disposed(by: disposeBag)
    }
    
    private func setUpTableView() {
        tableViewProxy = TableViewProxy(tableView: tableView)
        
        //Album Data
        viewModel.likedAlbumData
            .observeOn(MainScheduler.instance)
            .map { albumTupleArray -> [TableCellData] in
                return albumTupleArray.map { albumTuple -> TableCellData in
                    return TableCellData(title: albumTuple.0, subTitle: albumTuple.1, id: albumTuple.2, imageData: albumTuple.3, imageStream: albumTuple.4)
                }
            }
            .subscribe(onNext: { [unowned self] data in
                self.tableViewProxy.setTableViewData(data)
            })
            .disposed(by: disposeBag)
        
        //Album Details
        tableViewProxy.albumDetailsID
            .throttle(1.0, latest: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] id in
                self.viewModel.dispatch(action: .requestDetailsScene(albumId: id))
            })
            .disposed(by: disposeBag)
        
        //Delete Album
        tableViewProxy.deleteAlbumID
            .subscribe(onNext: { [unowned self] id in
                self.viewModel.dispatch(action: .deleteAlbum(id: id))
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func edit() {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            editButton.title = "Edit"
        } else {
            tableView.setEditing(true, animated: true)
            editButton.title = "Done"
        }
    }

    @IBAction func menu() {
        viewModel.dispatch(action: .requestMenuScene)
    }

}



