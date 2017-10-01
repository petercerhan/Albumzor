//
//  ChooseArtistViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/28/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum ArtistSearchOrigin {
    case icon(IndexPath)
    case search
}

protocol ChooseArtistViewControllerDelegate: class {
    func chooseArtistSceneComplete()
}

class ChooseArtistViewController: UIViewController {
    
    //REMOVE
    var appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    //MARK: - Dependencies
    
    let dataManager = (UIApplication.shared.delegate as! AppDelegate).dataManager!
    var viewModel: ChooseArtistViewModel!
    
    //MARK: - Interface Components
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var textField: UITextField!
    @IBOutlet var overlayView: UIView!
    @IBOutlet var doneButton: UIButton!
    
    //MARK: - State

    var searchActive = false
    var selectedCellPath: IndexPath?

    //MARK: - Rx
    
    let disposeBag = DisposeBag()
    
    //MARK: - Initialization
    
    static func createWith(storyBoard: UIStoryboard, viewModel: ChooseArtistViewModel) -> ChooseArtistViewController {
        let vc = storyBoard.instantiateViewController(withIdentifier: "ChooseArtistViewController") as! ChooseArtistViewController
        vc.viewModel = viewModel
        vc.bindViewModel()
        return vc
    }
    
    private func bindActions() {
        searchButton.rx.tap
            .withLatestFrom(viewModel.searchActive.asObservable()) { _, searchActive in
                return searchActive
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] searchActive in
                self.viewModel.dispatch(action: searchActive ? .cancelCustomSearch : .requestCustomSearch)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        viewModel.searchActive.asObservable()
            .observeOn(MainScheduler.instance)
            .skip(1)
            .subscribe(onNext: { [unowned self] active in
                if active {
                    self.animateInSearch()
                } else {
                    self.animateOutSearch()
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindActions()
        
        searchButton.imageEdgeInsets = UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0)
        overlayView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.cancelSearch)))
        
        textField.translatesAutoresizingMaskIntoConstraints = true
        
        if let layout = collectionView.collectionViewLayout as? ArtistCollectionViewLayout {
            layout.delegate = self
        }
    }
    
    //MARK: - User Actions
    
    func cancelSearch() {
        dismissKeyboard()
        animateOutSearch()
    }
    
    @IBAction func done() {
        if appDelegate.userSettings.isSeeded {
            viewModel.dispatch(action: .requestNextScene)
        } else {
            alert(title: nil, message: "Try choosing a few more artists!", buttonTitle: "Done")
        }
    }

    //MARK: - Animations
    
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
        dismissKeyboard()
        
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
        return viewModel.seedArtists.value.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChooseArtistCollectionViewCell", for: indexPath) as! ChooseArtistCollectionViewCell
        
        cell.label.text = viewModel.seedArtists.value[indexPath.item]
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
        label.text = viewModel.seedArtists.value[path.item]
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
            
            //replace with action dispatch//
            var newArtists = viewModel.seedArtists.value
            newArtists.remove(at: path.item)
            viewModel.seedArtists.value = newArtists
            
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
            viewModel.dispatch(action: .requestConfirmArtists(searchString: textField.text!))
        }
        
        return true
    }
    
}


