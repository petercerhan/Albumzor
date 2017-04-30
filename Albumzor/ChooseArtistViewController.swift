//
//  ChooseArtistViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/28/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

enum ArtistSearchOrigin {
    case icon(IndexPath)
    case search
}

protocol ChooseArtistViewControllerDelegate {
    func chooseArtistSceneComplete()
}

class ChooseArtistViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var textField: UITextField!
    @IBOutlet var overlayView: UIView!
    @IBOutlet var doneButton: UIButton!
    
    var appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    var delegate: ChooseArtistViewControllerDelegate?
    
    var searchActive = false
    
    let dataManager = (UIApplication.shared.delegate as! AppDelegate).dataManager!
    
    var selectedCellPath: IndexPath?
    var artists = ChooseArtistViewController.suggestedArtists
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchButton.imageEdgeInsets = UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0)
        overlayView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.cancelSearch)))
        
        textField.translatesAutoresizingMaskIntoConstraints = true
        
        if let layout = collectionView.collectionViewLayout as? ArtistCollectionViewLayout {
            layout.delegate = self
        }
    }
    
    @IBAction func search() {
        if searchActive {
            cancelSearch()
        } else {
            animateInSearch()
        }
    }

    func animateInSearch() {
        searchButton.isUserInteractionEnabled = false
        searchActive = true
        textField.center.x += view.frame.width
        overlayView.alpha = 0
        self.textField.isHidden = false
        self.overlayView.isHidden = false
        self.textField.becomeFirstResponder()
        
        UIView.animate(withDuration: 0.3,
                       animations: {
                        self.textField.center.x -= self.view.frame.width
                        self.overlayView.alpha = 0.8
        },
                       completion: {
                        _ in
                        self.searchButton.isUserInteractionEnabled = true
        })
    }
    
    func animateOutSearch() {
        searchButton.isUserInteractionEnabled = false
        textField.text = ""
        
        UIView.animate(withDuration: 0.3,
                       animations: {
                        self.textField.center.x += self.view.frame.width
                        self.overlayView.alpha = 0
                    },
                       completion: {
                        _ in
                        self.textField.center.x -= self.view.frame.width
                        self.textField.isHidden = true
                        self.overlayView.isHidden = true
                        self.searchActive = false
                        self.searchButton.isUserInteractionEnabled = true
                    })
    }
    
    func launchConfirmArtistScene(searchString: String, searchOrigin: ArtistSearchOrigin) {
        let vc = storyboard!.instantiateViewController(withIdentifier: "ConfirmArtistViewController") as! ConfirmArtistViewController
        vc.delegate = self
        vc.searchString = searchString
        vc.searchOrigin = searchOrigin
        present(vc, animated: true) {
            if self.searchActive {
                self.dismissKeyboard()
                self.animateOutSearch()
            }
        }
    }
    
    func cancelSearch() {
        dismissKeyboard()
        animateOutSearch()
    }
    
    @IBAction func done() {
        if appDelegate.userSettings.isSeeded {
            delegate?.chooseArtistSceneComplete()
        } else {
            alert(title: nil, message: "Try choosing a few more artists!", buttonTitle: "Done")
        }
    }
    
    func updateDoneButton() {
        //if enough albums, enable
        if dataManager.getAlbumsCount() >= 100 {
            doneButton.setTitleColor(Styles.themeOrange, for: .normal)
            appDelegate.userSettings.isSeeded = true
            appDelegate.saveUserSettings()
        }
    }
}

//MARK:- UICollectionViewDelegate

extension ChooseArtistViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let cell = collectionView.cellForItem(at: indexPath) as! ChooseArtistCollectionViewCell
        selectedCellPath = indexPath
        
        launchConfirmArtistScene(searchString: cell.label.text!, searchOrigin: .icon(indexPath))
        
        return true
    }
}

//MARK:- UICollectionViewDataSource

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
        cell.label.textColor = UIColor.white

        cell.layer.borderColor = Styles.lightBlue.cgColor
        //Corner radius seems to be asking too much of the collection view, which becomes very choppy
        //cell.layer.cornerRadius = 20.0
        cell.contentView.backgroundColor = Styles.lightBlue
        
        return cell
    }
}

extension ChooseArtistViewController: ArtistCollectionViewLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, sizeForLabelAtIndexPath path: IndexPath) -> CGSize {
        let label = UILabel()
        label.text = artists[path.item]
        label.font = UIFont.systemFont(ofSize: 19.0)
        label.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        label.sizeToFit()
        let size = label.frame.size
        
        //Add padded label vertical & horizontal padding
        return CGSize(width: size.width + CGFloat(20), height: size.height + CGFloat(14))
    }
}

//MARK:- ConfirmArtistViewControllerDelegate

extension ChooseArtistViewController: ConfirmArtistViewControllerDelegate {
    func artistChosen(spotifyID: String, searchOrigin: ArtistSearchOrigin) {
        //If artist was chosen from the collection view, remove that collection view item
        switch searchOrigin {
        case .icon(let path):
            (collectionView.collectionViewLayout as! ArtistCollectionViewLayout).clearCache()
            artists.remove(at: path.item)
            collectionView.deleteItems(at: [path])
            collectionView.reloadData()
        case .search:
            break
        }
        
        //add the artist's related artists
        dataManager.getRelatedArtists(artistID: spotifyID) {
            _ in
            DispatchQueue.main.async {
                self.updateDoneButton()
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func artistCanceled() {
        dismiss(animated: true, completion: nil)
    }
}

//MARK:- UITextFieldDelegate

extension ChooseArtistViewController: UITextFieldDelegate {
    
    func dismissKeyboard() {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text == "" {
            cancelSearch()
        } else {
            launchConfirmArtistScene(searchString: textField.text!, searchOrigin: .search)
        }
        
        return true
    }
    
}

//MARK:- Suggested Artist Data

extension ChooseArtistViewController {
    
    static let suggestedArtists = ["Radiohead",
                          "Elliott Smith",
                          "Nick Drake",
                          "Pixies",
                          "Faith No More",
                          "The Smashing Pumpkins",
                          "Weezer",
                          "Pixies",
                          "Alice in Chains",
                          "Sufjan Stevens",
                          "Bon Iver",
                          "Wilco",
                          "Yo La Tengo",
                          "Pavement",
                          "Red Hot Chili Peppers",
                          "Nine Inch Nails",
                          "Bjork",
                          "Wu-Tang Clan",
                          "Nas",
                          "DJ Shadow",
                          "Mobb Deep",
                          "Public Enemy",
                          "Beastie Boys",
                          "Rage Against The Machine",
                          "Kendrick Lamar",
                          "OutKast",
                          "Kanye West",
                          "Jay-Z",
                          "The Pharcyde",
                          "Lauryn Hill",
                          "Mos Def",
                          "Nujabes",
                          "Run the Jewels",
                          "Public Enemy",
                          "Miles Davis",
                          "Charles Mingus",
                          "John Coltrane",
                          "Nina Simone",
                          "Frank Sinatra",
                          "A Tribe Called Quest",
                          "Aretha Franklin",
                          "Bob Marley",
                          "Tom Waits",
                          "Sade",
                          "Norah Jones",
                          "Duke Ellington",
                          "Megadeth",
                          "Black Sabbath",
                          "Judas Priest",
                          "Iron Maiden",
                          "Metallica",
                          "Megadeth",
                          "The Beatles",
                          "The Beach Boys",
                          "Queen",
                          "Prince",
                          "Depeche Mode",
                          "Fleetwood Mac",
                          "No Doubt",
                          "The Kinks",
                          "Simon and Garfunkel",
                          "Eminem",
                          "Boston",
                          "Elvis Presley",
                          "U2",
                          "Yes",
                          "Megadeth",
                          "David Bowie",
                          "The Cure",
                          "The Clash",
                          "Talking Heads",
                          "Dead Kennedys",
                          "Streetlight Manifesto",
                          "Pink Floyd",
                          "The Jimi Hendrix Experience",
                          "Led Zeppelin",
                          "Bob Dylan",
                          "The Doors",
                          "Bruce Springsteen",
                          "The Who",
                          "The Velvet Underground",
                          "Frank Zappa",
                          "Lynyrd Skynyrd",
                          "The Band",
                          "Creedence Clearwater Revival",
                          "Chuck Berry",
                          "Frederic Chopin",
                          "Beethoven",
                          "Mozart",
                          "Tchaikovsky",
                          "Adele",
                          "Lady Gaga",
                          "Beyonce",
                          "Shania Twain",
                          "Megadeth",
                          "Rihanna",
                          "Taylor Swift",
                          "Drake",
                          "Lil Wayne",
                          "Katy Perry",
                          "Amy Winehouse",
                          "Michael Jackson",
                          "The Rolling Stones",
                          "Guns n' Roses",
                          "Stevie Wonder",
                          "Drake",
                          "Alicia Keys",
                          "Patti Smith",
                          "Grateful Dead",
                          "AC/DC",
                          "Fleetwood Mac",
                          "P!nk"]
}
