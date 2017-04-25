//
//  ViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/12/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
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
    
    
    @IBAction func chooseArtists() {
        let vc = storyboard!.instantiateViewController(withIdentifier: "ChooseArtistViewController")
        present(vc, animated: true, completion: nil)
    }
    
    

    
    func testAlbumData() {
        let request = NSFetchRequest<Album>(entityName: "Album")
        request.sortDescriptors = [NSSortDescriptor(key: "seen", ascending: false)]
        
        do {
            let albumsTry = try self.stack.context.fetch(request)
            for album in albumsTry {
                print("Album \(album.name!), seen: \(album.seen)")
            }
        } catch {
            
        }
    }
    
    func testArtistData() {
        let request = NSFetchRequest<Artist>(entityName: "Artist")
        request.sortDescriptors = [NSSortDescriptor(key: "seenAlbums", ascending: false)]
        do {
            let artists = try self.stack.context.fetch(request)
            for artist in artists {
                print("Artist \(artist.name!), Score: \(artist.score)")
            }
        } catch {
            
        }
        print("-")
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

extension ViewController: UITableViewDelegate {
    
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
            stack.context.delete(album)
            stack.save()
        }
    }
    
}

//MARK:- UITableViewDataSource

extension ViewController: UITableViewDataSource {
    
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

        if let imageData = album.imageData, let image = UIImage(data: imageData as Data) {
            cell.albumImageView.image = image
        } else {
            cell.albumImageView.image = nil
        }
        
        cell.selectionStyle = .none
        
//        downloadImage(imagePath: album.largeImage!) { data, error in
//            
//            if let error = error {
//                print("error: \(error)")
//            } else {
//                DispatchQueue.main.async {
//                    cell.albumImageView.image = UIImage(data: data!)
//                }
//            }
//        
//        }
        
        return cell
    }
    
    //trying out suggested code from Udacity
    
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


// MARK: - CoreDataTableViewController: NSFetchedResultsControllerDelegate

extension ViewController: NSFetchedResultsControllerDelegate {
    
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

extension ViewController: AlbumsContainerViewControllerDelegate {
    func findAlbumsHome() {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - AlbumDetailsViewControllerDelegate

extension ViewController: AlbumDetailsViewControllerDelegate {
    
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

extension ViewController: AudioPlayerDelegate {
    
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




