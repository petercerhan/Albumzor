//
//  ViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/12/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var findAlbumsButton: AnimatedButton!
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var menuButton: UIBarButtonItem!
    
    let userSettings = (UIApplication.shared.delegate as! AppDelegate).userSettings
    let stack = (UIApplication.shared.delegate as! AppDelegate).coreDataStack
    let audioPlayer = (UIApplication.shared.delegate as! AppDelegate).audioPlayer
    
    var currentAlbumTracks: [Track]?
    
    var fetchedResultsController : NSFetchedResultsController<Album>? {
        didSet {
            fetchedResultsController?.delegate = self
            executeSearch()
            tableView.reloadData() 
        }
    }
    
    var imageBuffer = [String : UIImage]()

    //MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        findAlbumsButton.backgroundColor = Styles.themeBlue
        menuButton.imageInsets = UIEdgeInsetsMake(7.0, 2.0, 7.0, 2.0)
        
        findAlbumsButton.baseColor = Styles.themeBlue
        findAlbumsButton.highlightedColor = Styles.shadedThemeBlue
        
        configureFetchedResultsController()
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
        audioPlayer.delegate = self
        tableView.reloadData()
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
        let vc = AlbumsContainerViewController()
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }

    @IBAction func menu() {
        let vc = storyboard!.instantiateViewController(withIdentifier: "MenuTableViewController") as! MenuTableViewController
        vc.menuDelegate = self
        navigationController?.pushViewController(vc, animated: true)
    }

}

//MARK:- UITableViewDelegate

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let album = fetchedResultsController!.object(at: indexPath)
        
        let dataManager = (UIApplication.shared.delegate as! AppDelegate).dataManager!
        
        currentAlbumTracks = dataManager.getTracks(forAlbum: album.objectID)
        
        let vc = storyboard!.instantiateViewController(withIdentifier: "AlbumDetailsViewController") as! AlbumDetailsViewController
//        vc.albumImage = UIImage(data: album.imageData as! Data)
//        vc.tracks = currentAlbumTracks
//        vc.album = album
        
//        vc.trackPlaying = nil
//        vc.audioState = .noTrack
        
//        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        editButton.title = "Done"
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        if editButton.title != "Edit" {
            editButton.title = "Edit"
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let album = fetchedResultsController!.object(at: indexPath)
            let artist = album.artist!
            
            if artist.priorSeed, artist.album?.count == 1 {
                stack.context.delete(artist)
            } else {
                stack.context.delete(album)
            }
            
            stack.save()
        }
    }
}

//MARK: - UITableViewDataSource

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let fc = fetchedResultsController {
            return fc.sections![section].numberOfObjects
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let album = fetchedResultsController!.object(at: indexPath) as Album
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumTableViewCell") as! AlbumTableViewCell
        cell.nameLabel.text = album.name!.cleanAlbumName()
        cell.artistLabel.text = album.artist!.name!
        cell.albumImageView.image = nil

        let albumID = album.objectID
        let spotifyID = album.id!
        let backgroundContext = stack.networkingContext
        
        //get UIImage from the image buffer if it's there, else get the data from core data and build the UIImage if there, else try to fetch over network
        if let image = imageBuffer[spotifyID] {
            cell.albumImageView.image = image
        } else {
            backgroundContext.perform {
                //Get an album in the background context. Cannot use "album" which is in the main context!
                var bgAlbum: Album!
                do {
                    bgAlbum = try self.stack.networkingContext.existingObject(with: albumID) as! Album
                } catch {
                    
                }
                //get image from core data
                if let imageData = bgAlbum.smallImageData {
                    DispatchQueue.main.async {
                        let image = UIImage(data: imageData as Data)
                        cell.albumImageView.image = image
                        self.imageBuffer[spotifyID] = image
                    }
                    //get image over network
                } else {
                    self.downloadImage(imagePath: bgAlbum.smallImage!) { imageData, error in
                        if let imageData = imageData {
                           
                            backgroundContext.perform {
                                bgAlbum.smallImageData = imageData as NSData?
                                do {
                                    try backgroundContext.save()
                                } catch {
                                    
                                }
                                self.stack.save()
                            }
                            
                            DispatchQueue.main.async {
                                let image = UIImage(data: imageData as Data)
                                cell.albumImageView.image = image
                                self.imageBuffer[spotifyID] = image
                            }
                            
                        }
                    }
                }
            }
        }
        
        cell.albumImageView.layer.borderColor = UIColor.lightGray.cgColor
        cell.albumImageView.layer.borderWidth = 0.5
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func downloadImage(imagePath: String, completionHandler: @escaping (_ imageData: Data?, _ errorString: String?) -> Void) {
        let session = URLSession.shared
        let imgURL = NSURL(string: imagePath)
        let request: NSURLRequest = NSURLRequest(url: imgURL! as URL)
        
        let task = session.dataTask(with: request as URLRequest) {data, response, downloadError in
            
            if downloadError != nil {
                completionHandler(nil, "Could not download image \(imagePath)")
            } else {
                completionHandler(data, nil)
            }
        }
        
        task.resume()
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

//MARK: - AlbumsContainerViewControllerDelegate

extension HomeViewController: AlbumsContainerViewControllerDelegate {
    func findAlbumsHome() {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - AlbumDetailsViewControllerDelegate

extension HomeViewController: AlbumDetailsViewControllerDelegate {
    
    func playTrack(atIndex index: Int) {
        
        guard let urlString = currentAlbumTracks?[index].previewURL, let url = URL(string: urlString) else {
            couldNotPlay()
            return
        }
        
        self.audioPlayer.playTrack(url: url)
    }
    
    func pauseAudio() {
        audioPlayer.pause()
    }
    
    func resumeAudio() {
        audioPlayer.play()
    }
    
    func stopAudio() {
        audioPlayer.stop()
    }
    
    func dismiss() {
        stopAudio()
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - AudioPlayerDelegate

extension HomeViewController: AudioPlayerDelegate {
    
    func beganLoading() {
        if let vc = presentedViewController as? AlbumDetailsViewController {
//            vc.audioBeganLoading()
        }
        //no action needed
    }
    
    func beganPlaying() {
        if let vc = presentedViewController as? AlbumDetailsViewController {
//            vc.audioBeganPlaying()
        }
    }
    
    func paused() {
        if let vc = presentedViewController as? AlbumDetailsViewController {
//            vc.audioPaused()
        }
    }
    
    func stopped() {
        if let vc = presentedViewController as? AlbumDetailsViewController {
//            vc.audioStopped()
        }
    }
    
    func couldNotPlay() {
        if let vc = presentedViewController as? AlbumDetailsViewController {
//            vc.audioCouldNotPlay()
        }
    }
    
}

//MARK: - Menu Delegate

extension HomeViewController: MenuDelegate {
    func refreshAlbumDisplay() {
        configureFetchedResultsController()
    }
}



