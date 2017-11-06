//
//  HomeViewModel.swift
//  Albumzor
//
//  Created by Peter Cerhan on 11/4/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import RxSwift

protocol HomeViewModelDelegate: class {
    func requestMenuScene(_ homeViewModel: HomeViewModel)
    func requestSuggestAlbumsScene(_ homeViewModel: HomeViewModel)
    func requestDetailsScene(_ homeViewModel: HomeViewModel)
}

enum HomeSceneAction {
    case requestMenuScene
    case requestSuggestAlbumsScene
    case requestDetailsScene(albumId: String)
    case deleteAlbum(id: String)
}

class HomeViewModel {
    
    //MARK: - Dependencies
    
    private weak var delegate: HomeViewModelDelegate?
    private let likedAlbumsStateController: LikedAlbumsStateController
    private let userSettingsStateController: UserSettingsStateController
    
    //MARK: - State
    
    private(set) lazy var likedAlbumData: Observable<[(String, String, String, Data?, Observable<UIImage>?)]> = {
        return self.likedAlbumsStateController.likedAlbums
            .filter { $0 != nil }
            .map { $0! }
            .map { albumDataArray -> [(String, String, String, Data?, Observable<UIImage>?)] in
                return albumDataArray.map { albumTuple -> (String, String, String, Data?, Observable<UIImage>?) in
                    let albumData = albumTuple.0
                    let imageObservable = albumTuple.1
                    return (albumData.cleanName, albumData.artistName ?? "", albumData.id, albumData.smallImageData, imageObservable)
                }
            }
            .shareReplay(1)
    }()
    
    //MARK: - Rx
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Initialization
    
    init(delegate: HomeViewModelDelegate, likedAlbumsStateController: LikedAlbumsStateController, userSettingsStateController: UserSettingsStateController) {
        self.delegate = delegate
        self.likedAlbumsStateController = likedAlbumsStateController
        self.userSettingsStateController = userSettingsStateController
        
        bindLikedAlbumsStateController()
    }
    
    private func bindLikedAlbumsStateController() {
        likedAlbumsStateController.detailsActive
            .subscribe(onNext: { [unowned self] isActive in
                if isActive {
                    self.delegate?.requestDetailsScene(self)
                }
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - Dispatch Actions
    
    func dispatch(action: HomeSceneAction){
        switch action {
        case .requestMenuScene:
            handle_requestMenuScene()
        case .requestSuggestAlbumsScene:
            handle_requestSuggestAlbumsScene()
        case .requestDetailsScene(let id):
            handle_requestDetailsScene(albumID: id)
        case .deleteAlbum(let id):
            handle_deleteAlbum(id: id)
        }
    }
    
    private func handle_requestMenuScene() {
        delegate?.requestMenuScene(self)
    }
    
    private func handle_requestSuggestAlbumsScene() {
        delegate?.requestSuggestAlbumsScene(self)
    }
    
    private func handle_requestDetailsScene(albumID: String) {
        likedAlbumsStateController.getDetailsForAlbum(albumID: albumID)
    }
    
    private func handle_deleteAlbum(id: String) {
        likedAlbumsStateController.deleteAlbum(id: id)
    }
    
}


