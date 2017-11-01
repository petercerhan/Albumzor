//
//  SuggestAlbumsViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 4/1/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

//error - tried and failed to retrieve sample audio; noTrack - no attempt has been made to retrieve a track
enum AudioState_old {
    case loading, playing, paused, error, noTrack
}

protocol SuggestAlbumsViewControllerDelegate : NSObjectProtocol {
    func quit()
    func batteryComplete(liked: Int)
}

class SuggestAlbumsViewController: UIViewController {
    
    //MARK: - Interface Components
    
    @IBOutlet var topLabel: UILabel!
    @IBOutlet var defaultView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var artistLabel: UILabel!
    
    @IBOutlet var quitButton: UIButton!
    @IBOutlet var dislikeButton: UIButton!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var audioButton: UIButton!
    @IBOutlet var spotifyButtonContainer: UIView!
    @IBOutlet var spotifyIndicator: UIImageView!
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    var currentAlbumView: CGDraggableView!
    var nextAlbumView: CGDraggableView!

    //MARK: - Dependencies
    
    fileprivate var viewModel: SuggestAlbumsViewModel!
    
    
    //REMOVE
    
    weak var delegate: SuggestAlbumsViewControllerDelegate!
    var appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    let dataManager = (UIApplication.shared.delegate as! AppDelegate).dataManager!
    var audioPlayer = (UIApplication.shared.delegate as! AppDelegate).audioPlayer
    
    //
    
    
    //MARK: - State
    
    private lazy var currentImageView: UIImageView = {
        let imageView = UIImageView()
        self.viewModel.currentAlbumArt
            .observeOn(MainScheduler.instance)
            .bind(to: imageView.rx.image)
            .disposed(by: self.disposeBag)
        
        return imageView
    }()
    
    private lazy var nextImageView: UIImageView = {
        let imageView = UIImageView()
        self.viewModel.nextAlbumArt
            .observeOn(MainScheduler.instance)
            .bind(to: imageView.rx.image)
            .disposed(by: self.disposeBag)

        return imageView
    }()
    
    var albumArt: [UIImage]!
    var albums: [Album]!
    var likedAlbums = 0
    
    var currentAlbumTracks: [Track]?
    var nextAlbumTracks: [Track]?
    
    var currentIndex: Int = 0
    
    var audioState: AudioState_old = .noTrack
    
    var trackPlaying: Int?
    
    var initialLayoutConfigured = false
    
    var buttonsEnabled = true
    
    //MARK: - Rx
    
    private var disposeBag = DisposeBag()
    
    //MARK: - Initialization
    
    static func createWith(storyBoard: UIStoryboard, viewModel: SuggestAlbumsViewModel) -> SuggestAlbumsViewController {
        let vc = storyBoard.instantiateViewController(withIdentifier: "SuggestAlbumsViewController") as! SuggestAlbumsViewController
        vc.viewModel = viewModel
        return vc
    }
    
    //MARK: - Bind UI
    
    func bindUI() {
        
        let _ = currentImageView
        let _ = nextImageView
        
        //Album Title
        viewModel.currentAlbumTitle
            .observeOn(MainScheduler.instance)
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        //Artist name
        viewModel.currentAlbumArtistName
            .observeOn(MainScheduler.instance)
            .bind(to: artistLabel.rx.text)
            .disposed(by: disposeBag)
        
        //Audio Control
        
        //Audio Control Title
        viewModel.audioState
            .observeOn(MainScheduler.instance)
            .map { audioState -> String in
                switch audioState {
                case .error:
                    return "!"
                default:
                    return ""
                }
            }
            .bind(to: audioButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
        
        //Audio Control Image
        viewModel.audioState
            .observeOn(MainScheduler.instance)
            .map { audioState -> UIImage? in
                switch audioState {
                case .none, .paused:
                    return UIImage(named: "Play")
                case .playing:
                    return UIImage(named: "Pause")
                default:
                    return nil
                }
            }
            .bind(to: audioButton.rx.image(for: .normal))
            .disposed(by: disposeBag)
        
        //Audio Control isHidden
        viewModel.audioState
            .observeOn(MainScheduler.instance)
            .map { audioState -> Bool in
                switch audioState {
                case .loading:
                    return true
                default:
                    return false
                }
            }
            .bind(to: audioButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        //Audio Control loading indicator
        viewModel.audioState
            .observeOn(MainScheduler.instance)
            .map { audioState -> Bool in
                switch audioState {
                case .loading:
                    return true
                default:
                    return false
                }
            }
            .bind(to: activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
    }
    
    private func bindAlbumStream() {
        
        //Album Stream
        viewModel.currentAlbumTitle
            .skip(1)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] _ in
                self.currentAlbumView.removeFromSuperview()
                self.currentAlbumView = self.nextAlbumView
                self.currentAlbumView.isUserInteractionEnabled = true
                
                self.nextAlbumView = self.configureAlbumView(imageSource: self.viewModel.nextAlbumArt)
                self.nextAlbumView.isUserInteractionEnabled = false
                self.view.insertSubview(self.nextAlbumView, belowSubview: self.currentAlbumView)
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - Bind Actions
    
    private func bindActions() {
        
        //Audio Control
        audioButton.rx.tap
            .withLatestFrom(viewModel.audioState) { (_, audioState) -> AudioState in
                return audioState
            }
            .filter { audioState in
                audioState == AudioState.paused || audioState == AudioState.playing
            }
            .subscribe(onNext: { [unowned self] audioState in
                switch audioState {
                case AudioState.paused:
                    self.viewModel.dispatch(action: .resumeAudio)
                case AudioState.playing:
                    self.viewModel.dispatch(action: .pauseAudio)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    //MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        audioPlayer.delegate = self
        subscribeToNotifications()
        
        bindUI()
        bindActions()
    }
    
    func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        if !initialLayoutConfigured {
            
            currentAlbumView = configureAlbumView(imageSource: viewModel.currentAlbumArt)
            view.addSubview(currentAlbumView)
            
            nextAlbumView = configureAlbumView(imageSource: viewModel.nextAlbumArt)
            nextAlbumView.isUserInteractionEnabled = false
            view.insertSubview(nextAlbumView, belowSubview: currentAlbumView)
            
            
            configureAudioButton()
            configureQuitButton()
            
            autoPlay()
            
            initialLayoutConfigured = true
            
            bindAlbumStream()
        }
    }
    
    private func configureAlbumView(imageSource: Observable<UIImage?>) -> CGDraggableView {
        let albumView = CGDraggableView(frame: defaultView.frame)
        albumView.delegate = self
        albumView.addShadow()
        albumView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        albumView.bindImageSource(imageSource.skipWhile{ $0 == nil }.take(1))
        return albumView
    }
    
    private func configureAudioButton() {
        audioButton.imageEdgeInsets = UIEdgeInsetsMake(11.0, 11.0, 11.0, 11.0)
        audioButton.contentMode = .center
    }
    
    private func configureQuitButton() {
        quitButton.imageEdgeInsets = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)
        quitButton.contentMode = .center
    }
    
    //MARK: - New Actions
    
    @IBAction func likeDispatch() {
//        viewModel.dispatch(action: .likeAlbum)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func appWillResignActive() {
        if let currentAlbumView = currentAlbumView {
            currentAlbumView.resetViewPositionAndTransformations()
        }
    }
    
    
    
    

    
    
    
    //MARK:- User Actions
    
    @IBAction func openInSpotify() {
        if !buttonsEnabled {
            return
        }
        UIApplication.shared.open(URL(string:"https://open.spotify.com/album/\(albums[currentIndex].id!)")!, options: [:], completionHandler: nil)
    }
    
    @IBAction func like() {
        
        //setting .isEnabled or .isUserInteractionEnabled does not seem to apply quickly enough; buttons can be hit multiple times quickly, leading to unpredictable results
        if !buttonsEnabled {
            return
        }
        buttonsEnabled = false
        currentAlbumView.isUserInteractionEnabled = false
        
        let rotationAngle = 2 * CGFloat(Double.pi) / 16.0
        let transform = CGAffineTransform(rotationAngle: rotationAngle)
        let finalTransform = transform.scaledBy(x: 0.93, y: 0.93)
        
        let exitDistance = view.frame.size.width
        
        UIView.animate(withDuration: 0.25,
                       animations: {
                        self.currentAlbumView.center.x += exitDistance
                        self.currentAlbumView.center.y -= 20
                        self.currentAlbumView.transform = finalTransform
                        
                    },
                       completion: {
                        _ in
                        self.currentAlbumView.removeFromSuperview()
                        self.buttonsEnabled = true
                        self.reviewAlbum(liked: true)
                    })
        
    }
    
    @IBAction func dislike() {
        
        if !buttonsEnabled {
            return
        }
        buttonsEnabled = false
        currentAlbumView.isUserInteractionEnabled = false
        
        let rotationAngle = -2 * CGFloat(Double.pi) / 16.0
        let transform = CGAffineTransform(rotationAngle: rotationAngle)
        let finalTransform = transform.scaledBy(x: 0.93, y: 0.93)
        
        let exitDistance = view.frame.size.width
        
        UIView.animate(withDuration: 0.25,
                       animations: {
                        self.currentAlbumView.center.x -= exitDistance
                        self.currentAlbumView.center.y -= 20
                        self.currentAlbumView.transform = finalTransform
                        
                    },
                       completion: { _ in
                        self.currentAlbumView.removeFromSuperview()
                        self.buttonsEnabled = true
                        self.reviewAlbum(liked: false)
                    })
    }

    @IBAction func quit() {
        audioPlayer.stop()
        delegate.quit()
    }
    
    @IBAction func audioControl() {
        
        switch audioState {
        case .playing:
            pauseAudio()
        case .paused:
            resumeAudio()
        case .noTrack:
            playTopTrack()
        default:
            break
        }
        
    }
    
    func setButtons(enabled: Bool) {
        quitButton.isEnabled = enabled
        likeButton.isUserInteractionEnabled = enabled
        dislikeButton.isUserInteractionEnabled = enabled
        spotifyButtonContainer.isUserInteractionEnabled = enabled
    }

    //MARK:- Manage likes
    
    fileprivate func reviewAlbum(liked: Bool) {
        viewModel.dispatch(action: .reviewAlbum(liked: liked))
    }
    
    
    //PRIOR
    func album(liked: Bool) {
        audioPlayer.stop()
        
        dataManager.seen(album: albums[currentIndex].objectID)
        
        if liked {
            likedAlbums += 1
            dataManager.like(album: albums[currentIndex].objectID, imageData: UIImagePNGRepresentation(albumArt[currentIndex]))
        }
        
        //if last album has been reviewed, go to next steps view
        if currentIndex == albums.count - 1 {
            audioPlayer.stop()
            animateOut()
            return
        }
        
        currentIndex += 1
        
        //update title
        if currentIndex < albums.count {
            titleLabel.text = albums[currentIndex].name!.cleanAlbumName()
            artistLabel.text = albums[currentIndex].artist!.name!
            titleLabel.alpha = 1.0
            artistLabel.alpha = 1.0
        }
        
        currentAlbumView = nextAlbumView
        currentAlbumView.isUserInteractionEnabled = true
        
        //add bottom album unless we are on the final album of the battery
        if currentIndex < albums.count - 1 {
            nextAlbumView = CGDraggableView(frame: defaultView.frame)
            nextAlbumView.imageView.image = albumArt[currentIndex + 1]
            nextAlbumView.addShadow()
            nextAlbumView.delegate = self
            view.insertSubview(nextAlbumView, belowSubview: currentAlbumView)
            nextAlbumView.isUserInteractionEnabled = false
        } else {
            nextAlbumView = nil
        }
        
        //get tracks
        currentAlbumTracks = nextAlbumTracks
        autoPlay()
        
        if currentIndex == albums.count - 1 {
            nextAlbumTracks = nil
        } else {
            nextAlbumTracks = dataManager.getTracks(forAlbum: albums[currentIndex + 1].objectID)
        }
    }
    //
    
    
    
    //MARK: - Animations
    func animateOut() {
        setButtons(enabled: false)
        currentAlbumView.isUserInteractionEnabled = false
        
        titleLabel.alpha = 0.0
        artistLabel.alpha = 0.0
        spotifyButtonContainer.alpha = 0.0
        activityIndicator.stopAnimating()
        
        UIView.animate(withDuration: 0.5,
                       animations: {
                        self.quitButton.alpha = 0.0
                        self.dislikeButton.alpha = 0.0
                        self.likeButton.alpha = 0.0
                        self.audioButton.alpha = 0.0
                        self.spotifyIndicator.alpha = 0.0
        },
                       completion: {
                        _ in
                        self.delegate.batteryComplete(liked: self.likedAlbums)
        })
    }
    
}

//MARK:- CGDraggableViewDelegate

extension SuggestAlbumsViewController: CGDraggableViewDelegate {
    func swipeComplete(direction: SwipeDirection) {
        setButtons(enabled: true)
        if direction == .right {
            reviewAlbum(liked: true)
        } else {
            reviewAlbum(liked: false)
        }
    }

    func tapped() {
        
        viewModel.dispatch(action: .showDetails)
        
//        let vc = storyboard!.instantiateViewController(withIdentifier: "AlbumDetailsViewController") as! AlbumDetailsViewController
//        vc.albumImage = albumArt[currentIndex]
//        vc.tracks = currentAlbumTracks
//        vc.album = albums[currentIndex]
//        
//        vc.trackPlaying = trackPlaying
//        vc.audioState = audioState
//        
//        vc.delegate = self
//        present(vc, animated: true, completion: nil)
    }
    
    func swipeBegan() {
        setButtons(enabled: false)
        titleLabel.alpha = 0.4
        artistLabel.alpha = 0.4
    }
    
    func swipeCanceled() {
        setButtons(enabled: true)
        titleLabel.alpha = 1.0
        artistLabel.alpha = 1.0
    }
}

//MARK:- Handle Audio / AlbumDetailsViewControllerDelegate
//playTrack(atIndex:), pauseAudio(), stopAudio(), and resumeAudio() called internally by SuggestAlbumsViewController, and are also AlbumDetailsViewController Delegate functions

extension SuggestAlbumsViewController: AlbumDetailsViewControllerDelegate {
    
    func playTrack(atIndex index: Int) {
        set(audioState: .loading, controlEnabled: false)
        
        guard let urlString = currentAlbumTracks?[index].previewURL, let url = URL(string: urlString) else {
            //could not play track
            set(audioState: .error, controlEnabled: false)
            couldNotPlay()
            return
        }

        trackPlaying = index
        self.audioPlayer.playTrack(url: url)
    }
    
    //Automatically play the sample of the most popular track on the album
    func autoPlay() {
        if !(appDelegate.userSettings.autoplay) {
            set(audioState: .noTrack, controlEnabled: true)
            return
        }
        playTopTrack()
    }
    
    func playTopTrack() {
        //get most popular track ..
        var mostPopularTrackIndex = 0
        var maxPopularity = 0
        
        guard let currentAlbumTracks = currentAlbumTracks, currentAlbumTracks.count > 0 else {
            couldNotPlay()
            return
        }
        
        for (index, track) in currentAlbumTracks.enumerated() {
            if Int(track.popularity) > maxPopularity {
                maxPopularity = Int(track.popularity)
                mostPopularTrackIndex = index
            }
        }
        
        //play track
        playTrack(atIndex: mostPopularTrackIndex)
    }
    
    func pauseAudio() {
        set(audioState: .paused, controlEnabled: false)
        audioPlayer.pause()
    }
    
    func resumeAudio() {
        set(audioState: .playing, controlEnabled: false)
        audioPlayer.play()
    }
    
    func stopAudio() {
        audioPlayer.stop()
    }
    
    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    func set(audioState: AudioState_old, controlEnabled: Bool) {
//        self.audioState = audioState
//        audioButton.isUserInteractionEnabled = controlEnabled
//
//        activityIndicator.stopAnimating()
//
//        switch audioState {
//        case .noTrack:
//            audioButton.setTitle("", for: .normal)
//            audioButton.setImage(UIImage(named: "Play"), for: .normal)
//            audioButton.isHidden = false
//        case .loading:
//            activityIndicator.startAnimating()
//            audioButton.isHidden = true
//        case .playing:
//            audioButton.setTitle("", for: .normal)
//            audioButton.setImage(UIImage(named: "Pause"), for: .normal)
//            audioButton.isHidden = false
//        case .paused:
//            audioButton.setTitle("", for: .normal)
//            audioButton.setImage(UIImage(named: "Play"), for: .normal)
//            audioButton.isHidden = false
//        case .error:
//            audioButton.isHidden = false
//            audioButton.setTitle("!", for: .normal)
//            audioButton.setImage(nil, for: .normal)
//        }
    }

}

//MARK:- AudioPlayerDelegate

extension SuggestAlbumsViewController: AudioPlayerDelegate {
    
    func beganLoading() {
//        if let vc = presentedViewController as? AlbumDetailsViewController {
////            vc.audioBeganLoading()
//        }
        //no action needed
    }
    
    func beganPlaying() {
        set(audioState: .playing, controlEnabled: true)
        
//        if let vc = presentedViewController as? AlbumDetailsViewController {
////            vc.audioBeganPlaying()
//        }
    }
    
    func paused() {
        set(audioState: .paused, controlEnabled: true)
        
//        if let vc = presentedViewController as? AlbumDetailsViewController {
////            vc.audioPaused()
//        }
    }
    
    func stopped() {
//        if let vc = presentedViewController as? AlbumDetailsViewController {
////            vc.audioStopped()
//        }
        //no action needed
    }
    
    func couldNotPlay() {
        set(audioState: .error, controlEnabled: false)
        
//        if let vc = presentedViewController as? AlbumDetailsViewController {
////            vc.audioCouldNotPlay()
//        }
    }

}


