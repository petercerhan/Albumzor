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
    
    //MARK: - Rx
    
    var disposeBag = DisposeBag()
    
    //MARK: - Initialization
    
    static func createWith(storyBoard: UIStoryboard, viewModel: ConfirmArtistViewModel) -> ConfirmArtistViewController {
        let vc = storyBoard.instantiateViewController(withIdentifier: "ConfirmArtistViewController") as! ConfirmArtistViewController
        vc.viewModel = viewModel
        
        return vc
    }
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI()
        bindActions()
    }
    
    //MARK: - Bind UI
    
    private func bindUI() {
        bindUI_ArtistLabel()
        bindUI_ArtistImage()
        bindUI_ArtistLoading()
        bindUI_ErrorMessages()
        bindUI_ActivityIndicator()
    }
    
    private func bindUI_ArtistLabel() {
        viewModel.confirmationArtistName
            .observeOn(MainScheduler.instance)
            .bind(to: artistLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func bindUI_ArtistImage() {
        viewModel.confirmArtistImage
            .observeOn(MainScheduler.instance)
            .bind(to: imageView.rx.image)
            .disposed(by: disposeBag)
    }
    
    private func bindUI_ArtistLoading() {
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
        
        bindUI_ArtistLoading_DislikeButton(artistSearchActiveObservable)
        bindUI_ArtistLoading_LikeButton(artistSearchActiveObservable)
        bindUI_ArtistLoading_SpotifyButton(artistSearchActiveObservable)
        bindUI_ArtistLoading_SpotifyButtonContainer(artistSearchActiveObservable)
        bindUI_ArtistLoading_QuitButton(artistSearchActiveObservable)
    }
    
    private func bindUI_ArtistLoading_DislikeButton(_ artistSearchActiveObservable: Observable<Bool>) {
        artistSearchActiveObservable
            .map{ !($0) }
            .bind(to: dislikeButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    private func bindUI_ArtistLoading_LikeButton(_ artistSearchActiveObservable: Observable<Bool>) {
        artistSearchActiveObservable
            .map{ !($0) }
            .bind(to: likeButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    private func bindUI_ArtistLoading_SpotifyButton(_ artistSearchActiveObservable: Observable<Bool>) {
        artistSearchActiveObservable
            .map{ !($0) }
            .bind(to: spotifyButtonContainer.rx.isUserInteractionEnabled)
            .disposed(by: disposeBag)
    }
    
    private func bindUI_ArtistLoading_SpotifyButtonContainer(_ artistSearchActiveObservable: Observable<Bool>) {
        artistSearchActiveObservable
            .map{ $0 ? 0.6 : 1.0}
            .bind(to: spotifyButtonContainer.rx.alpha)
            .disposed(by: disposeBag)
    }
    
    private func bindUI_ArtistLoading_QuitButton(_ artistSearchActiveObservable: Observable<Bool>) {
        artistSearchActiveObservable
            .map{ !($0) }
            .bind(to: quitButton.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    private func bindUI_ErrorMessages() {
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
    }
    
    private func bindUI_ActivityIndicator() {
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
    
    //MARK: - Bind Actions
    
    private func bindActions() {
        bindAction_SpotifyButton()
        bindAction_QuitButton()
        bindAction_DislikeButton()
        bindAction_LikeButton()
    }
    
    private func bindAction_SpotifyButton() {
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
    
    private func bindAction_QuitButton() {
        quitButton.rx.tap
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] _ in
                self.viewModel.dispatch(action: .cancel)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindAction_DislikeButton() {
        dislikeButton.rx.tap
            .throttle(1.0, latest: false, scheduler: MainScheduler.instance)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] _ in
                self.rejectArtist()
            })
            .disposed(by: disposeBag)
    }
    
    private func rejectArtist() {
        disposeBag = DisposeBag()
        viewModel.dispatch(action: .cancel)
    }
    
    private func bindAction_LikeButton() {
        likeButton.rx.tap
            .throttle(1.0, latest: false, scheduler: MainScheduler.instance)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] _ in
                self.selectArtist()
            })
            .disposed(by: disposeBag)
    }
    
    private func selectArtist() {
        disposeBag = DisposeBag()
        viewModel.dispatch(action: .confirmArtist)
    }
    
}




