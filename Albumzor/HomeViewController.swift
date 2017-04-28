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

    var imageBuffer = [String : UIImage]()
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var findAlbumsButton: AnimatedButton!
    @IBOutlet var editButton: UIBarButtonItem!
    
    let stack = (UIApplication.shared.delegate as! AppDelegate).coreDataStack
    var audioPlayer = (UIApplication.shared.delegate as! AppDelegate).audioPlayer
    
    var currentAlbumTracks: [Track]?
    
    var fetchedResultsController : NSFetchedResultsController<Album>? {
        didSet {
            fetchedResultsController?.delegate = self
            executeSearch()
            tableView.reloadData() 
        }
    }
    
    //MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureFetchedResultsController()
        
        findAlbumsButton.backgroundColor = Styles.themeBlue
    }
    
    func configureFetchedResultsController() {
        let request = NSFetchRequest<Album>(entityName: "Album")
        let predicate = NSPredicate(format: "(liked = true)")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        request.predicate = predicate
        
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        
        fetchedResultsController = frc
    }
    
    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        audioPlayer.delegate = self
    }
    
    @IBAction func edit() {
        if tableView.isEditing {
            editButton.title = "Edit"
            tableView.setEditing(false, animated: true)
            
        } else {
            editButton.title = "Done"
            tableView.setEditing(true, animated: true)
        }
    }
    
    @IBAction func discoverAlbums() {
        let vc = AlbumsContainerViewController()
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }

    @IBAction func menu() {
        let vc = storyboard!.instantiateViewController(withIdentifier: "MenuTableViewController")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    

    
    func getSpotifyAPIKey() -> String? {
        
        let filePath = Bundle.main.path(forResource: "SpotifyApiKey", ofType: "txt")

        print("file path: \(filePath)")
        
        do {
            let textString = try String(contentsOfFile: filePath!)
            return textString
        } catch {
            print("error reading file to string")
        }
        
        return nil
    }
    
}

//MARK:- UITableViewDelegate

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let album = fetchedResultsController!.object(at: indexPath)
        
        let dataManager = (UIApplication.shared.delegate as! AppDelegate).dataManager!
        
        currentAlbumTracks = dataManager.getTracks(forAlbum: album.objectID)
        
        let vc = storyboard!.instantiateViewController(withIdentifier: "AlbumDetailsViewController") as! AlbumDetailsViewController
        vc.albumImage = UIImage(data: album.imageData as! Data)
        vc.tracks = currentAlbumTracks
        vc.album = album
        
        vc.trackPlaying = nil
        vc.audioState = .noTrack
        
        vc.delegate = self
        present(vc, animated: true, completion: nil)
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

//MARK:- UITableViewDataSource

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

        let albumID = album.objectID
        let spotifyID = album.id!
        let backgroundContext = stack.networkingContext
        
        if let image = imageBuffer[spotifyID] {
            cell.albumImageView.image = image
        } else {
            backgroundContext.perform {
                var bgAlbum: Album!
                
                do {
                    bgAlbum = try self.stack.networkingContext.existingObject(with: albumID) as! Album
                } catch {
                    print("Core data error")
                }
                
                if let imageData = bgAlbum.imageData {
                    DispatchQueue.main.async {
                        let image = UIImage(data: imageData as Data)
                        cell.albumImageView.image = image
                        self.imageBuffer[spotifyID] = image
                    }
                }
            }
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
}


// MARK: - CoreDataTableViewController: NSFetchedResultsControllerDelegate

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

//MARK: - AlbumsContainerViewController

extension HomeViewController: AlbumsContainerViewControllerDelegate {
    func findAlbumsHome() {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - AlbumDetailsViewControllerDelegate

extension HomeViewController: AlbumDetailsViewControllerDelegate {
    
    func playTrack(atIndex index: Int) {
        
        guard let urlString = currentAlbumTracks?[index].previewURL else {
            couldNotPlay()
            return
        }
        
        guard let url = URL(string: urlString) else {
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

//MARK:- AudioPlayerDelegate

extension HomeViewController: AudioPlayerDelegate {
    
    func beganLoading() {
        if let vc = presentedViewController as? AlbumDetailsViewController {
            vc.audioBeganLoading()
        }
        //no action needed
    }
    
    func beganPlaying() {
        if let vc = presentedViewController as? AlbumDetailsViewController {
            vc.audioBeganPlaying()
        }
    }
    
    func paused() {
        if let vc = presentedViewController as? AlbumDetailsViewController {
            vc.audioPaused()
        }
    }
    
    func stopped() {
        if let vc = presentedViewController as? AlbumDetailsViewController {
            vc.audioStopped()
        }
    }
    
    func couldNotPlay() {
        if let vc = presentedViewController as? AlbumDetailsViewController {
            vc.audioCouldNotPlay()
        }
    }
    
}




