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

class ConfirmArtistViewController: UIViewController {
    
    //MARK: - Dependencies
    
    var viewModel: ConfirmArtistViewModel!
    
    //MARK: - Interface Components
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var artistLabel: UILabel!
    @IBOutlet var dislikeButton: UIButton!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var spotifyButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var quitButton: UIButton!
    @IBOutlet var spotifyButtonContainer: UIView!
    
    //MARK: - State
    
    //Remove
    var confirmSessionComplete = false
    var searchString: String!
    var searchOrigin: ArtistSearchOrigin!
    var spotifyID: String?
    //remove
    
    //MARK: - Rx
    
    var disposeBag = DisposeBag()
    
    //MARK: - Initialization
    
    static func createWith(storyBoard: UIStoryboard, viewModel: ConfirmArtistViewModel, searchString: String, searchOrigin: ArtistSearchOrigin) -> ConfirmArtistViewController {
        let vc = storyBoard.instantiateViewController(withIdentifier: "ConfirmArtistViewController") as! ConfirmArtistViewController
        vc.viewModel = viewModel
        
        //Remove
        vc.searchString = searchString
        vc.searchOrigin = searchOrigin
        //remove
        
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
        
        //Search artist error messages
        viewModel.loadConfirmArtistState
            .observeOn(MainScheduler.instance)
            .map { operationState -> Error? in
                switch operationState {
                case .error(let error):
                    return error
                default:
                    return nil
                }
            }
            .filter { $0 != nil }
            .subscribe(onNext: { [unowned self] error in
                guard let error = error as? NetworkRequestError else { return }
                switch error {
                case .connectionFailed:
                    self.alert(title: "Network Error", message: "Please check your internet connection", buttonTitle: "Dismiss") { action in
                        self.viewModel.dispatch(action: .cancel)
                    }
                default:
                    self.alert(title: "Artist not found!", message: "Note: some artists may be unavailable.", buttonTitle: "Dismiss") { action in
                        self.viewModel.dispatch(action: .cancel)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        
        //All loading state
        //Is this needed? just replace with observing actual image..
        //Then could remove loadConfirmArtistImageOperationState altogether
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
    
    private func bindActions() {
        spotifyButton.rx.tap
            .withLatestFrom(viewModel.confirmationArtistID) { _, artistID in
                return artistID
            }
            .filter { artistID in
                artistID != nil
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] artistID in
                self.viewModel.dispatch(action: .openInSpotify(url: "https://open.spotify.com/artist/\(artistID!)"))
            })
            .disposed(by: disposeBag)
        
    }
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI()
        bindActions()
    }
    
    //MARK: - User Actions
    
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
}




