//
//  SeedArtistStateController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 9/26/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import RxSwift

class SeedArtistStateController {
    
    //MARK: - Dependencies
    
    private let mediaLibraryService: MediaLibraryServiceProtocol
    private let remoteDataService: RemoteDataServiceProtocol
    private let localDatabaseService: LocalDatabaseServiceProtocol
    
    //MARK: - State
    
    let seedArtists = Variable<[String]>([])

    let searchActive = Variable<Bool>(false)
    
    let confirmationActive = Variable<Bool>(false)
    let confirmationArtistName = Variable<String?>(nil)
    let confirmArtistIndex = Variable<Int?>(nil)
    let loadConfirmArtistState = Variable<DataOperationState>(.none)
    let confirmArtistData = Variable<ArtistData?>(nil)
    let loadConfirmArtistImageOperationState = Variable<DataOperationState>(.none)
    let confirmArtistImage = Variable<UIImage?>(nil)
    
    let totalAlbumsSeeded = Variable<Int>(0)

    //MARK: - Rx
    
    let disposeBag = DisposeBag()

    //MARK: - Initialization
    
    init(mediaLibraryService: MediaLibraryServiceProtocol, remoteDataService: RemoteDataServiceProtocol, localDatabaseService: LocalDatabaseServiceProtocol) {
        self.mediaLibraryService = mediaLibraryService
        self.remoteDataService = remoteDataService
        self.localDatabaseService = localDatabaseService
    }

    //MARK: - Interface
    
    func fetchSeedArtistsFromMediaLibrary() {
        mediaLibraryService.fetchArtistsFromMediaLibrary()
            .subscribe(onNext: { [unowned self] artists in
                self.seedArtists.value = artists
            })
            .disposed(by: disposeBag)
    }
    
    func customArtistSearch(showSearch: Bool) {
        searchActive.value = showSearch
    }
    
    func setConfirmArtistIndex(index: Int) {
        confirmArtistIndex.value = index
    }
    
    //Fetch foncifmration artist data
    func searchArtistForConfirmation(artistString: String) {
        
        loadConfirmArtistState.value = .operationBegan
        confirmationArtistName.value = artistString
        confirmationActive.value = true
        
        let artistObservable = remoteDataService.fetchArtistInfo(artistName: artistString)
        
        //load result
        artistObservable
            .subscribe(onNext: { [unowned self] artistData in
                self.confirmArtistData.value = artistData
                //fetchArtistInfo method validates that an imageURL exists. It is conceivable that an artist could not have images; that artist would come up as unfound in the spotify service as currently written
                self.fetchImageFrom(urlString: artistData.imageURL!)
            })
            .disposed(by: disposeBag)
        
        //loading status
        //necessary to have a second observer?
        artistObservable.map {_ -> Void in}
            .subscribe(onError: { [unowned self] error in
                self.loadConfirmArtistState.value = .error(error)
            }, onCompleted: { [unowned self] in
                self.loadConfirmArtistState.value = .operationCompleted
                self.loadConfirmArtistState.value = .none
            })
            .disposed(by: disposeBag)
    }
    
    //Fetch confirmation artist image
    func fetchImageFrom(urlString: String) {
        loadConfirmArtistImageOperationState.value = .operationBegan
        
        let imageObservable = remoteDataService.fetchImageFrom(urlString: urlString)
        
        imageObservable
            .subscribe(onNext: { [unowned self] image in
                self.confirmArtistImage.value = image
            })
            .disposed(by: disposeBag)
        
        imageObservable.map { _ -> Void in }
            .subscribe(onError: { [unowned self] error in
                self.loadConfirmArtistImageOperationState.value = .error(nil)
            }, onCompleted: { [unowned self] in
                self.loadConfirmArtistImageOperationState.value = .operationCompleted
                self.loadConfirmArtistImageOperationState.value = .none
            })
            .disposed(by: disposeBag)
    }
    
    func confirmArtist() {
        if let index = confirmArtistIndex.value  {
            var newValue = seedArtists.value
            _ = newValue.remove(at: index)
            seedArtists.value = newValue
        }
    }
    
    func endConfirmation() {
        loadConfirmArtistState.value = .none
        confirmationArtistName.value = nil
        confirmationActive.value = false
        loadConfirmArtistImageOperationState.value = .none
        confirmArtistImage.value = nil
        
        confirmArtistIndex.value = nil
    }
    
    //1.
    func addSeedArtist(artistData data: ArtistData? = nil) {
        //use data either fed to function or last received from download service; else return
        guard let artistData = data ?? confirmArtistData.value else {
            return
        }
        
        //if confirmation panel was launched, update to remove the confirmed artist from the options list
        if let index = confirmArtistIndex.value  {
            var newValue = seedArtists.value
            _ = newValue.remove(at: index)
            seedArtists.value = newValue
        }
        
        //fetch related artists
        let x = remoteDataService.fetchRelatedArtists(id: artistData.id)
        
        x.subscribe(onNext: { [unowned self] artistArray in
            self.checkArtists(artistArray: artistArray)
        })
        .disposed(by: disposeBag)
        
    }
    
    //2.
    //For each artist, is the artist already in the data? if so, skip
    private func checkArtists(artistArray: [ArtistData]) {
        for artist in artistArray {
            
            localDatabaseService.getArtist(id: artist.id)
                .subscribe(onNext: { [unowned self] value in
                    if let value = value {
                        //If yes, increment references and continue..
                        print("artist \(value.name) found")
                    } else {
                        //commence add artist process
                        self.fetchAlbumsForArtist(artist: artist)
                    }
                })
                .disposed(by: disposeBag)
            
        }
    }
    
    //3.
    //Fetch list of albums
    private func fetchAlbumsForArtist(artist: ArtistData) {

        remoteDataService.fetchArtistAlbums(id: artist.id)
            .subscribe(onNext: { [unowned self] albumDataArray in
                
                self.fetchAlbumDetails(albums: albumDataArray, artist: artist)
            })
            .disposed(by: disposeBag)
    }
    
    //4.
    //Fetch full album info
    private func fetchAlbumDetails(albums: [AbbreviatedAlbumData], artist artistIn: ArtistData) {
        
        var artist = artistIn
        
        remoteDataService.fetchAlbumDetails(albums: albums)
            .subscribe(onNext: { [unowned self] albumDataArray in
             
                //remove duplicates
                var sortedAlbums = albumDataArray.sorted
                {
                    if $0.name.cleanAlbumName() == $1.name.cleanAlbumName() {
                        return $0.popularity > $1.popularity
                    } else {
                        return $0.name.cleanAlbumName().localizedCaseInsensitiveCompare($1.name.cleanAlbumName()) == ComparisonResult.orderedAscending
                    }
                }
                
                var filteredAlbums = [AlbumData]()
                for (index, album) in sortedAlbums.enumerated() {
                    
                    if index == 0 ||
                        !(album.name.cleanAlbumName().localizedCaseInsensitiveCompare(sortedAlbums[index - 1].name.cleanAlbumName()) == ComparisonResult.orderedSame)
                    {
                        filteredAlbums.append(album)
                    }
                }
                
                artist.totalAlbums = filteredAlbums.count
                
                //save albums + artist
                self.localDatabaseService.saveArtist(artist: artist, withAlbums: filteredAlbums)
                self.getTotalSeededAlbums()
            })
            .disposed(by: disposeBag)
        
    }
    
    //5.
    //Update total seeded albums
    private func getTotalSeededAlbums() {
        localDatabaseService.countUnseenArtists()
            .subscribe(onNext: { [unowned self] count in
                self.totalAlbumsSeeded.value = count
            })
            .disposed(by: disposeBag)
    }
    
}







