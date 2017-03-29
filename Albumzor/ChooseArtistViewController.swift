//
//  ChooseArtistViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/28/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

class ChooseArtistViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func done() {
        dismiss(animated: true, completion: nil)
    }
    

}

extension ChooseArtistViewController: UICollectionViewDelegate {
    
}

extension ChooseArtistViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ChooseArtistViewController.suggestedArtists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChooseArtistCollectionViewCell", for: indexPath) as! ChooseArtistCollectionViewCell
        
        cell.label.text = ChooseArtistViewController.suggestedArtists[indexPath.item]
        
        return cell
    }
}

extension ChooseArtistViewController: UICollectionViewDelegateFlowLayout {
    
}

//MARK:- Artist Data

extension ChooseArtistViewController {
    static let suggestedArtists = ["Red Hot Chili Peppers",
                          "Wu Tang Clan",
                          "The Rolling Stones",
                          "Lady Gaga",
                          "Ja Rule",
                          "Mozart",
                          "Weezer",
                          "Taylor Swift",
                          "Green Day",
                          "The Pixies",
                          "The Killers",
                          "The Monkeys",
                          "Beyonce",
                          "Jay-Z",
                          "Kanye West",
                          "Amy Winehouse",
                          "Kansas",
                          "Kid Cudi",
                          "Lupe Fiasco",
                          "M.I.A.",
                          "Michael Jackson",
                          "Nas",
                          "Nelly",
                          "Old Crow Medicine Show",
                          "Pink Floyd",
                          "Prince",
                          "David Bowie",
                          "R.E.M.",
                          "Ray Charles",
                          "Rihanna",
                          "Roy Orbison",
                          "Shaggy",
                          "Smash Mouth",
                          "Sublime",
                          "Talking Heads",
                          "U2",
                          "The Velvet Underground",
                          "Willie Nelson"]
}
