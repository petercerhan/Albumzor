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

//Remove
//error - tried and failed to retrieve sample audio; noTrack - no attempt has been made to retrieve a track
enum AudioState_old {
    case loading, playing, paused, error, noTrack
}
//remove

//Remove
protocol SuggestAlbumsViewControllerDelegate : NSObjectProtocol {
    func quit()
    func batteryComplete(liked: Int)
}
//remove

class SuggestAlbumsViewController: UIViewController {
    
    //MARK: - Interface Components
    
    @IBOutlet var topLabel: UILabel!
    @IBOutlet var defaultView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var artistLabel: UILabel!
    
    @IBOutlet var homeButton: UIButton!
    
    @IBOutlet var dislikeButton: UIButton!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var audioButton: UIButton!
    @IBOutlet var spotifyButtonContainer: UIView!
    @IBOutlet var spotifyIndicator: UIImageView!
    @IBOutlet var spotifyButton: UIButton!
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    var currentAlbumView: CGDraggableView!
    var nextAlbumView: CGDraggableView!

    //MARK: - Dependencies
    
    fileprivate var viewModel: SuggestAlbumsViewModel!
    
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

    
    var initialLayoutConfigured = false
    
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
        
        viewModel.currentAlbumTitle
            .observeOn(MainScheduler.instance)
            .map { _ -> CGFloat in
                return CGFloat(1.0)
            }
            .bind(to: titleLabel.rx.alpha)
            .disposed(by: disposeBag)
        
        //Artist name
        viewModel.currentAlbumArtistName
            .observeOn(MainScheduler.instance)
            .bind(to: artistLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.currentAlbumArtistName
            .observeOn(MainScheduler.instance)
            .map {  _ -> CGFloat in
                return CGFloat(1.0)
            }
            .bind(to: artistLabel.rx.alpha)
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
                audioState == AudioState.paused || audioState == AudioState.playing || audioState == AudioState.none
            }
            .subscribe(onNext: { [unowned self] audioState in
                switch audioState {
                case AudioState.paused:
                    self.viewModel.dispatch(action: .resumeAudio)
                case AudioState.playing:
                    self.viewModel.dispatch(action: .pauseAudio)
                case AudioState.none:
                    self.viewModel.dispatch(action: .autoPlay)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        //Spotify Button
        spotifyButton.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                self.viewModel.dispatch(action: .openInSpotify)
            })
            .disposed(by: disposeBag)
        
        //Home Button
        homeButton.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                self.viewModel.dispatch(action: .home)
            })
            .disposed(by: disposeBag)
    }
    
    //MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToNotifications()
        
        bindUI()
        bindActions()
    }
    
     //Move to separate object?
    private func subscribeToNotifications() {
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
            configureHomeButton()
            
            
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
    
    private func configureHomeButton() {
        homeButton.imageEdgeInsets = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)
        homeButton.contentMode = .center
    }
    
    //MARK: - New Actions
    
    func appWillResignActive() {
        if let currentAlbumView = currentAlbumView {
            currentAlbumView.resetViewPositionAndTransformations()
        }
    }
    
    //MARK: - User Actions
    
    @IBAction func like() {
        
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
                        }, completion: {
                            _ in
                            self.reviewAlbum(liked: true)
                        })
        
    }
    
    @IBAction func dislike() {
        
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
                        self.reviewAlbum(liked: false)
                    })
    }
    
    //MARK:- Manage likes
    
    fileprivate func reviewAlbum(liked: Bool) {
        viewModel.dispatch(action: .reviewAlbum(liked: liked))
    }
    
}

//MARK:- CGDraggableViewDelegate

extension SuggestAlbumsViewController: CGDraggableViewDelegate {
    func swipeComplete(direction: SwipeDirection) {
        if direction == .right {
            reviewAlbum(liked: true)
            viewModel.dispatch(action: .reviewAlbum(liked: true))
        } else {
            viewModel.dispatch(action: .reviewAlbum(liked: false))
        }
    }

    func tapped() {
        viewModel.dispatch(action: .showDetails)
    }
    
    func swipeBegan() {
        titleLabel.alpha = 0.4
        artistLabel.alpha = 0.4
    }
    
    func swipeCanceled() {
        titleLabel.alpha = 1.0
        artistLabel.alpha = 1.0
    }
}


