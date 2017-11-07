//
//  SortOptionsTableViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 5/4/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum AlbumSortType: Int {
    case dateAdded = 0
    case albumName = 1
    case artist = 2
}

class SortOptionsTableViewController: UITableViewController {

    //MARK: - Dependencies
    
    private var viewModel: SortOptionsViewModel!
    
    //MARK: - Interface Components
    
    @IBOutlet var check1: UILabel!
    @IBOutlet var check2: UILabel!
    @IBOutlet var check3: UILabel!

    //MARK: - Rx
    
    private let disposeBag = DisposeBag()

    //MARK: - Initialization
    
    static func createWith(storyBoard: UIStoryboard, viewModel: SortOptionsViewModel) -> SortOptionsTableViewController {
        let vc = storyBoard.instantiateViewController(withIdentifier: "SortOptionsTableViewController") as! SortOptionsTableViewController
        vc.viewModel = viewModel
        return vc
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sort Albums By"
        bindUI()
    }
    
    private func bindUI() {
        
        //1st cell
        viewModel.albumSortType
            .map { sortType -> String in
                switch sortType {
                case .dateAdded:
                    return "✓"
                case .albumName:
                    return ""
                case .artist:
                    return ""
                }
            }
            .observeOn(MainScheduler.instance)
            .bind(to: check1.rx.text)
            .disposed(by: disposeBag)
        
        //2nd cell
        viewModel.albumSortType
            .map { sortType -> String in
                switch sortType {
                case .dateAdded:
                    return ""
                case .albumName:
                    return "✓"
                case .artist:
                    return ""
                }
            }
            .observeOn(MainScheduler.instance)
            .bind(to: check2.rx.text)
            .disposed(by: disposeBag)
        
        //3rd cell
        viewModel.albumSortType
            .map { sortType -> String in
                switch sortType {
                case .dateAdded:
                    return ""
                case .albumName:
                    return ""
                case .artist:
                    return "✓"
                }
            }
            .observeOn(MainScheduler.instance)
            .bind(to: check3.rx.text)
            .disposed(by: disposeBag)
        
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            viewModel.dispatch(action: .setSortType(.dateAdded))
        case 1:
            viewModel.dispatch(action: .setSortType(.albumName))
        case 2:
            viewModel.dispatch(action: .setSortType(.artist))
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }


}
