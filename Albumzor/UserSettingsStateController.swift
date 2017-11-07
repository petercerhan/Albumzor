//
//  UserSettingsStateController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 9/17/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import RxSwift

class UserSettingsStateController {

    //MARK: - Dependencies
    
    private let archiveService: ArchivingServiceProtocol
    
    //MARK: - State
    
    let instructionsSeen: Variable<Bool>!
    let isSeeded: Variable<Bool>!
    let isAutoplayEnabled: Variable<Bool>!
    let albumSortType: Variable<Int>!
    
    //MARK: - Initialization
    
    init(archiveService: ArchivingServiceProtocol) {
        self.archiveService = archiveService
        
        let userSettings = archiveService.unarchiveObject(forKey: "userSettings") as? UserSettings ?? UserSettings()

        instructionsSeen = Variable(userSettings.instructionsSeen)
        isSeeded = Variable(userSettings.isSeeded)
        isAutoplayEnabled = Variable(userSettings.autoplay)
        albumSortType = Variable(userSettings.albumSortType)
    }
    
    //MARK: - Interface
    
    func setIsSeeded(_ isSeeded: Bool) {
        self.isSeeded.value = isSeeded
        archive()
    }
    
    func setInstructionsSeen(_ instructionsSeen: Bool) {
        self.instructionsSeen.value = instructionsSeen
        archive()
    }
    
    func setSortType(_ sortType: Int) {
        self.albumSortType.value = sortType
        archive()
    }
    
    private func archive() {
        let userSettings = UserSettings(instructionsSeen: instructionsSeen.value, isSeeded: isSeeded.value, autoplay: isAutoplayEnabled.value, albumSortType: albumSortType.value)
        self.archiveService.archive(object: userSettings, forKey: "userSettings")
    }
    
    //MARK: - Utilities
    
    func reset() {
        let userSettings = UserSettings()
        archiveService.archive(object: userSettings, forKey: "userSettings")
    }
    
}

