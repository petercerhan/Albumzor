//
//  ConfirmArtistViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/30/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol ConfirmArtistViewControllerDelegate: class {
    func artistChosen(spotifyID: String, searchOrigin: ArtistSearchOrigin)
    func artistCanceled()
}

class ConfirmArtistViewController: UIViewController {

    //MARK: - Interface Components
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var artistLabel: UILabel!
    @IBOutlet var dislikeButton: UIButton!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var quitButton: UIButton!
    @IBOutlet var spotifyButtonContainer: UIView!
    
    //MARK: - Dependencies
    
    var viewModel: ConfirmArtistViewModel!
    
    weak var delegate: ConfirmArtistViewControllerDelegate!
    var client = SpotifyClient.sharedInstance()
    
    //MARK: - State
    
    var confirmSessionComplete = false
    
    var searchString: String!
    var searchOrigin: ArtistSearchOrigin!
    
    var spotifyID: String?
    
    //MARK: - Rx
    
    var disposeBag = DisposeBag()
    
    //MARK: - Initialization
    
    static func createWith(storyBoard: UIStoryboard, viewModel: ConfirmArtistViewModel, searchString: String, searchOrigin: ArtistSearchOrigin) -> ConfirmArtistViewController {
        let vc = storyBoard.instantiateViewController(withIdentifier: "ConfirmArtistViewController") as! ConfirmArtistViewController
        vc.viewModel = viewModel
        vc.searchString = searchString
        vc.searchOrigin = searchOrigin
        return vc
    }
    
    //MARK: - Bind UI
    
    private func bindUI() {
        viewModel.confirmationArtistName
            .observeOn(MainScheduler.instance)
            .bind(to: artistLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.confirmArtistImage
            .observeOn(MainScheduler.instance)
            .bind(to: imageView.rx.image)
            .disposed(by: disposeBag)
        
        //artist loading state
        let artistSearchActiveObservable = viewModel.loadConfirmArtistState
            .observeOn(MainScheduler.instance)
            .map { operationState -> Bool in
                switch operationState {
                case .none, .operationCompleted:
                    return false
                default:
                    return true
                }
            }
            .shareReplay(1)
        
        //dislike button
        artistSearchActiveObservable
            .map{ !($0) }
            .bind(to: dislikeButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        //like button
        artistSearchActiveObservable
            .map{ !($0) }
            .bind(to: likeButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        //spotify button
        artistSearchActiveObservable
            .map{ !($0) }
            .bind(to: spotifyButtonContainer.rx.isUserInteractionEnabled)
            .disposed(by: disposeBag)
        
        artistSearchActiveObservable
            .map{ $0 ? 0.6 : 1.0}
            .bind(to: spotifyButtonContainer.rx.alpha)
            .disposed(by: disposeBag)
        
        //cancel load button
        artistSearchActiveObservable
            .map{ !($0) }
            .bind(to: quitButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        //All loading state
        //Is this needed?
        _ = Observable.combineLatest(viewModel.loadConfirmArtistState, viewModel.loadConfirmArtistImageOperationState)
            { (artistLoadState, imageLoadState) -> Bool in
                let combinedState = (artistLoadState, imageLoadState)
                
                switch combinedState {
                case (.none, .operationCompleted),
                     (.none, .none),
                     (.operationCompleted, .none),
                     (.operationCompleted, .operationCompleted):
                    
                    return false
                default:
                    return true
                }
            }
            .observeOn(MainScheduler.instance)
            .bind(to: activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
    }
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI()
    }
    
    //MARK: - User Actions
    
    @IBAction func openInSpotify() {
        if let spotifyID = spotifyID {
            UIApplication.shared.open(URL(string:"https://open.spotify.com/artist/\(spotifyID)")!, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func quit() {
        viewModel.dispatch(action: .cancel)
    }
    
    @IBAction func selectArtist() {
        disposeBag = DisposeBag()
        viewModel.dispatch(action: .confirmArtist)
    }
    
    @IBAction func rejectArtist() {
        disposeBag = DisposeBag()
        viewModel.dispatch(action: .cancel)
    }
    
    func artistNotFound(networkError: Bool) {
        var title = ""
        var message = ""
        
        if networkError {
            title = "Network Error"
            message = "Please check you internet connection"
        } else {
            title = "Could not find \(searchString!)!"
            message = "Note: some artists may be unavailable."
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default) {
            action in
            self.delegate.artistCanceled()
        }
        alert.addAction(dismissAction)
        present(alert, animated: true, completion: nil)
        
    }

}


