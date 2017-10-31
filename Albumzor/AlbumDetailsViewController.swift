//
//  AlbumDetailsViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/27/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol AlbumDetailsViewControllerDelegate: NSObjectProtocol {
    func playTrack(atIndex index: Int)
    func pauseAudio()
    func resumeAudio()
    func stopAudio()
    func dismiss()
}

class AlbumDetailsViewController: UIViewController {
    
    //MARK: - Dependencies
    
    fileprivate var viewModel: AlbumDetailsViewModel!
    
    //MARK: - Interface Components
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var audioButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - State
    
    fileprivate var albumTitle: String?
    fileprivate var artistName: String?
    fileprivate var albumImage: UIImage?
    fileprivate var tracks: [(String, Int)]?
    
    //MARK: - Rx
    
    private let disposeBag = DisposeBag()
    
    //Remove
    weak var album: Album!
    
    //Index of currently playing track
    var trackPlaying: Int?
    
    var audioState: AudioState_old = .noTrack
    
    var delegate: AlbumDetailsViewControllerDelegate?
    
    //MARK: - Initialization
    
    static func createWith(storyBoard: UIStoryboard, viewModel: AlbumDetailsViewModel) -> AlbumDetailsViewController {
        let vc = storyBoard.instantiateViewController(withIdentifier: "AlbumDetailsViewController") as! AlbumDetailsViewController
        vc.viewModel = viewModel
        return vc
    }
    
    //MARK: - BindUI
    
    private func bindUI() {
        //Album Title
        viewModel.albumTitle
            .filter { $0 != nil }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] albumTitle in
                self.albumTitle = albumTitle
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        //Artist Name
        viewModel.artistName
            .filter { $0 != nil }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] artistName in
                self.artistName = artistName
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)

        //Album Art
        viewModel.albumImage
            .filter { $0 != nil }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] image in
                self.albumImage = image
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        //Track New
        viewModel.tracks
            .filter { $0 != nil }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] tracks in
                self.tracks = tracks
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        
        //Audio Control
        viewModel.audioState
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] audioState in
                let button = self.audioButton!
                let indicator = self.activityIndicator!
                
                switch audioState {
                case .none:
                    button.setTitle("", for: .normal)
                    button.setImage(UIImage(named: "Play"), for: .normal)
                    button.isHidden = false
                    indicator.stopAnimating()
                    print("none")
                case .loading:
                    indicator.startAnimating()
                    button.isHidden = true
                    print("loading")
                case .playing:
                    button.setTitle("", for: .normal)
                    button.setImage(UIImage(named: "Pause"), for: .normal)
                    button.isHidden = false
                    indicator.stopAnimating()
                    print("playing")
                case .paused:
                    button.setTitle("", for: .normal)
                    button.setImage(UIImage(named: "Play"), for: .normal)
                    button.isHidden = false
                    indicator.stopAnimating()
                    print("paused")
                case .error:
                    button.isHidden = false
                    button.setTitle("!", for: .normal)
                    button.setImage(nil, for: .normal)
                    indicator.stopAnimating()
                    print("error")
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func bindActions() {
        //Audio Control
        audioButton.rx.tap
            .withLatestFrom(viewModel.audioState) { (_, audioState) -> AudioState in
                return audioState
            }
            .filter { audioState in
                audioState == AudioState.paused || audioState == AudioState.playing || audioState == AudioState.error
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] audioState in
                switch audioState {
                case AudioState.paused:
                    self.viewModel.dispatch(action: .resumeAudio)
                case AudioState.playing:
                    self.viewModel.dispatch(action: .pauseAudio)
                case AudioState.error:
                    self.alert(title: nil, message: "Preview may not be available for all tracks", buttonTitle: "Dismiss")
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        //Open in Spotify
//        spotifyButton.rx.tap
//            .observeOn(MainScheduler.instance)
//            .subscribe(onNext: { [unowned self] _ in
//                self.viewModel.dispatch(action: .openInSpotify)
//            })
//            .disposed(by: disposeBag)
        
    }
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        
        bindUI()
        bindActions()
        
        
        configureAudioButton()
    }
    
    func configureAudioButton() {
        audioButton.imageEdgeInsets = UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0)
        audioButton.contentMode = .center
    }
    
    //MARK: - User Actions
    
    @IBAction func openInSpotify() {
        UIApplication.shared.open(URL(string:"https://open.spotify.com/album/\(album.id!)")!, options: [:], completionHandler: nil)
    }
    
    @IBAction func back() {
        viewModel.dispatch(action: .dismiss)
    }

}

//MARK:- TableViewDelegate

extension AlbumDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            viewModel.dispatch(action: .dismiss)
        } else {
            viewModel.dispatch(action: .playTrack(trackIndex: indexPath.item - 1))
            
            if let trackPlaying = trackPlaying, let priorCell = tableView.cellForRow(at: IndexPath(item: trackPlaying + 1, section: 0)) as? TrackTableViewCell {
                priorCell.titleLabel.font = UIFont.systemFont(ofSize: priorCell.titleLabel.font.pointSize)
            }
            
            trackPlaying = indexPath.item - 1
            
            let cell = tableView.cellForRow(at: indexPath) as! TrackTableViewCell
            cell.titleLabel.font = UIFont.boldSystemFont(ofSize: cell.titleLabel.font.pointSize)
        }
        
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.item == 0 {
            viewModel.dispatch(action: .dismiss)
            return false
        } else {
            return true
        }
    }
    
}

//MARK:- TableViewDataSource

extension AlbumDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tracks = tracks {
            return tracks.count + 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.item == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumDetailsCell") as! AlbumDetailsTableViewCell
            
            cell.albumImageView.image = albumImage
            cell.albumImageView.addShadow()
            cell.titleLabel.text = albumTitle
            cell.artistLabel.text = artistName
            
            cell.spotifyButtonCallback = { [unowned self] in
                self.viewModel.dispatch(action: .openInSpotify)
            }
            
            cell.selectionStyle = .none
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell") as! TrackTableViewCell
            
            cell.titleLabel.font = UIFont.systemFont(ofSize: cell.titleLabel.font.pointSize)
            cell.titleLabel.text = tracks?[indexPath.row - 1].0
            cell.numberLabel.text = "\(tracks![indexPath.row - 1].1)"
            
            cell.selectionStyle = .none
            
            if let trackPlaying = trackPlaying, trackPlaying == indexPath.row - 1 {
                cell.titleLabel.font = UIFont.boldSystemFont(ofSize: cell.titleLabel.font.pointSize)
            }
            
            return cell
        }
    }
    
}

