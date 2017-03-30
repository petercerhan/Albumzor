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
        if let layout = collectionView.collectionViewLayout as? ArtistCollectionViewLayout {
            layout.delegate = self
        }
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

extension ChooseArtistViewController: ArtistCollectionViewLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, sizeForLabelAtIndexPath path: IndexPath) -> CGSize {
        let label = UILabel()
        label.text = ChooseArtistViewController.suggestedArtists[path.item]
        label.font = UIFont.systemFont(ofSize: 18.0)
        label.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        label.sizeToFit()
        return label.frame.size
    }
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
