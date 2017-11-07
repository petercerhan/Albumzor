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
    
    //MARK: - Interface Components
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var findAlbumsButton: AnimatedButton!
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var menuButton: UIBarButtonItem!
    
    var tableViewProxy: TableViewProxy!
    
    //MARK: - Dependencies
    
    fileprivate var viewModel: HomeViewModel!
    
    
    
    //Remove
    let userSettings = (UIApplication.shared.delegate as! AppDelegate).userSettings
    let stack = (UIApplication.shared.delegate as! AppDelegate).coreDataStack
    //remove
    
    //MARK: - Rx
    
    let disposeBag = DisposeBag()
    
    
    //MARK: - Initialization
    
    static func createWith(storyBoard: UIStoryboard, viewModel: HomeViewModel) -> HomeViewController {
        let vc = storyBoard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        vc.viewModel = viewModel
        return vc
    }
    
    var fetchedResultsController : NSFetchedResultsController<Album>? {
        didSet {
            fetchedResultsController?.delegate = self
            executeSearch()
            tableView.reloadData() 
        }
    }
    
    //How to best implement this?
    var imageBuffer = [String : UIImage]()
    //
    
    //MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        findAlbumsButton.backgroundColor = Styles.themeBlue
        menuButton.imageInsets = UIEdgeInsetsMake(7.0, 2.0, 7.0, 2.0)
        
        findAlbumsButton.baseColor = Styles.themeBlue
        findAlbumsButton.highlightedColor = Styles.shadedThemeBlue
        
        setUpTableView()
        
        
        
        
//        configureFetchedResultsController()
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
    
    
    
    
    
    
    
    func configureFetchedResultsController() {
        guard let albumSortType = AlbumSortType(rawValue: userSettings.albumSortType) else {
            return
        }
        
        let request = NSFetchRequest<Album>(entityName: "Album")
        let predicate = NSPredicate(format: "(liked = true)")
        request.predicate = predicate
        
        switch albumSortType {
        case .dateAdded:
            request.sortDescriptors = [NSSortDescriptor(key: "likedDateTime", ascending: false)]
        case .albumName:
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        case .artist:
            request.sortDescriptors = [NSSortDescriptor(key: "artist.name", ascending: true)]
        }
        
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        
        fetchedResultsController = frc
    }
    
    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch _ as NSError {
                
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        tableView.reloadData()
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
    
    @IBAction func findAlbums() {
        viewModel.dispatch(action: .requestSuggestAlbumsScene)
    }

    @IBAction func menu() {
        viewModel.dispatch(action: .requestMenuScene)
    }

}

// MARK: - NSFetchedResultsControllerDelegate

extension HomeViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let set = IndexSet(integer: sectionIndex)
        
        switch (type) {
        case .insert:
            tableView.insertSections(set, with: .fade)
        case .delete:
            tableView.deleteSections(set, with: .fade)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch(type) {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}




