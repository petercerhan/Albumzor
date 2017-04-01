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
    
    var selectedCellPath: IndexPath?
    var artists = ChooseArtistViewController.suggestedArtists
    
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
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.backgroundColor = UIColor.red
        selectedCellPath = indexPath
        
        let vc = storyboard!.instantiateViewController(withIdentifier: "ConfirmArtistViewController") as! ConfirmArtistViewController
        vc.delegate = self
        present(vc, animated: true, completion: nil)
        
        return true
    }
}

extension ChooseArtistViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return artists.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChooseArtistCollectionViewCell", for: indexPath) as! ChooseArtistCollectionViewCell
        
        cell.label.text = artists[indexPath.item]

        cell.layer.borderWidth = 2.0
        cell.layer.borderColor = UIColor.blue.cgColor
        cell.layer.cornerRadius = 20.0
        cell.contentView.backgroundColor = UIColor.white
        
        return cell
    }
}

extension ChooseArtistViewController: ArtistCollectionViewLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, sizeForLabelAtIndexPath path: IndexPath) -> CGSize {
        let label = UILabel()
        label.text = artists[path.item]
        label.font = UIFont.systemFont(ofSize: 22.0)
        label.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        label.sizeToFit()
        let size = label.frame.size
        
        //Add padded label vertical & horiztonal padding
        return CGSize(width: size.width + CGFloat(20), height: size.height + CGFloat(14))
    }
}

//MARK:- ConfirmArtistViewControllerDelegate

extension ChooseArtistViewController: ConfirmArtistViewControllerDelegate {
    func artistChosen() {
        let cell = collectionView.cellForItem(at: selectedCellPath!) as! ChooseArtistCollectionViewCell
        cell.contentView.backgroundColor = UIColor.blue
        
        (collectionView.collectionViewLayout as! ArtistCollectionViewLayout).clearCache()
        artists.remove(at: selectedCellPath!.item)
        collectionView.deleteItems(at: [selectedCellPath!])
        collectionView.reloadData()                                   
        
        dismiss(animated: true, completion: nil)
    }
    
    func artistCanceled() {
        let cell = collectionView.cellForItem(at: selectedCellPath!) as! ChooseArtistCollectionViewCell
        cell.contentView.backgroundColor = UIColor.blue
        dismiss(animated: true, completion: nil)
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
                          "Willie Nelson",
                          "Capadonna",
                          "Lil Wayne",
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
                          "Willie Nelson",
                          "Capadonna",
                          "Lil Wayne",
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
                          "Willie Nelson",
                          "Capadonna",
                          "Lil Wayne",
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
                          "Willie Nelson",
                          "Capadonna",
                          "Lil Wayne",
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
                          "Willie Nelson",
                          "Capadonna",
                          "Lil Wayne",
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
                          "Willie Nelson",
                          "Capadonna",
                          "Lil Wayne"]
}
