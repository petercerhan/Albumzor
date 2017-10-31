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
    @IBOutlet var doneButton: UIButton!
    
    //MARK: - State
    
    fileprivate var albumTitle: String?
    fileprivate var artistName: String?
    fileprivate var albumImage: UIImage?
    fileprivate var tracks: [(String, Int)]?
    fileprivate var trackPlaying: Int?
    
    //MARK: - Rx
    
    private let disposeBag = DisposeBag()
    
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
        
        //Tracks
        viewModel.tracks
            .filter { $0 != nil }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] tracks in
                self.tracks = tracks
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        //Track Playing Index
        viewModel.trackPlayingIndex
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] trackIndex in
                self.trackPlaying = trackIndex
            })
            .disposed(by: disposeBag)
        
        //Audio
        
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
    
    private func bindActions() {
        //Audio Control
        audioButton.rx.tap
            .withLatestFrom(viewModel.audioState) { (_, audioState) -> AudioState in
                return audioState
            }
            .filter { audioState in
                audioState == AudioState.paused || audioState == AudioState.playing || audioState == AudioState.error
            }
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
        
        //Back
        doneButton.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                self.viewModel.dispatch(action: .dismiss)
            })
            .disposed(by: disposeBag)
        

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

}

//MARK:- TableViewDelegate

extension AlbumDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            viewModel.dispatch(action: .dismiss)
        } else {
            
            if let trackPlaying = trackPlaying, let priorCell = tableView.cellForRow(at: IndexPath(item: trackPlaying + 1, section: 0)) as? TrackTableViewCell {
                priorCell.titleLabel.font = UIFont.systemFont(ofSize: priorCell.titleLabel.font.pointSize)
            }
            
            viewModel.dispatch(action: .playTrack(trackIndex: indexPath.item - 1))
            
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

