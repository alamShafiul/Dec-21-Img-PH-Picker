//
//  ViewController.swift
//  Dec-19-Gallery
//
//  Created by Admin on 19/12/22.
//

import UIKit
import PhotosUI

class FirstVC: UIViewController {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var gridBtn: UIButton!
    
    @IBOutlet weak var listBtn: UIButton!
    
    var transitionState = 0
    
    var idxPath: IndexPath!
    
    var LAYOUT1: UICollectionViewCompositionalLayout!
    
    var LAYOUT2: UICollectionViewCompositionalLayout!
    
    var imageList: [UIImage] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }

    func setupCollectionView() {
        
        let inset = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        // layout - 1 START
        let item1Size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalHeight(1))
        let item1 = NSCollectionLayoutItem(layoutSize: item1Size)
        item1.contentInsets = inset
        
        let group1Size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1/3))
        let group1 = NSCollectionLayoutGroup.horizontal(layoutSize: group1Size, subitems: [item1])
        
        let section1 = NSCollectionLayoutSection(group: group1)
        
        let layout1 = UICollectionViewCompositionalLayout(section: section1)
        LAYOUT1 = layout1
        // layout - 1 END
        
        
        // layout - 2 START
        let item2Size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item2 = NSCollectionLayoutItem(layoutSize: item2Size)
        item2.contentInsets = inset
        let group2Size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1/2))
        let group2 = NSCollectionLayoutGroup.horizontal(layoutSize: group2Size, subitems: [item2])
        let section2 = NSCollectionLayoutSection(group: group2)
        let layout2 = UICollectionViewCompositionalLayout(section: section2)
        LAYOUT2 = layout2
        // layout - 2 END
        
        collectionView.collectionViewLayout = layout1
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let collectionNib = UINib(nibName: Constants.customCVCell, bundle: nil)
        collectionView.register(collectionNib, forCellWithReuseIdentifier: Constants.collectionNibCell)
    }
    
    
    
    
    @IBAction func addBtn(_ sender: Any) {
        //showImagePicker()
        showPHPicker()
    }
    
    @IBAction func gridBtnAction(_ sender: Any) {
        doTransition(btn: "gridBtn")
    }
    
    
    @IBAction func listBtnAction(_ sender: Any) {
        doTransition(btn: "listBtn")
    }
    
    func doTransition(btn: String) {
        gridBtn.isUserInteractionEnabled = false
        listBtn.isUserInteractionEnabled = false
        if(btn == "gridBtn") {
            collectionView.startInteractiveTransition(to: LAYOUT1) { [weak self] _,_ in
                guard let self = self else {
                    return
                }
                self.gridBtn.isUserInteractionEnabled = true
                self.listBtn.isUserInteractionEnabled = true
            }
        }
        else {
            collectionView.startInteractiveTransition(to: LAYOUT2) { [weak self] _,_ in
                guard let self = self else {
                    return
                }
                self.gridBtn.isUserInteractionEnabled = true
                self.listBtn.isUserInteractionEnabled = true
            }
        }
        collectionView.finishInteractiveTransition()
    }
    
    func showImagePicker() {
        let imgPickerController = UIImagePickerController()
        imgPickerController.delegate = self
        
        present(imgPickerController, animated: true)
    }
    
    func showPHPicker() {
        var phConfig = PHPickerConfiguration()
        phConfig.filter = .images
        phConfig.selectionLimit = Int.max
        let phPickerController = PHPickerViewController(configuration: phConfig)
        phPickerController.delegate = self
        
        present(phPickerController, animated: true)
    }
    

}

extension FirstVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageList.append(originalImage)
            collectionView.reloadData()
        }
        picker.dismiss(animated: true)
    }
}

extension FirstVC: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: {
                [weak self] object,_ in
                guard let self = self else {
                    return
                }
                print(Thread.current)
                if let originalImage = object as? UIImage {
                    DispatchQueue.main.async {
                        self.imageList.append(originalImage)
                        self.collectionView.reloadData()
                    }
                }
            })
        }
        picker.dismiss(animated: true)
    }
}

extension FirstVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //idxPath = indexPath
        //performSegue(withIdentifier: Constants.gotoDet, sender: self)
        let alertVC = UIAlertController(title: "Hey!", message: "Do you want to?", preferredStyle: .actionSheet)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
            [weak self] _ in
            
            guard let self = self else {
                return
            }
            self.saveToLocal(indexPath: indexPath)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            _ in
            alertVC.dismiss(animated: true)
        })
        
        alertVC.addAction(saveAction)
        alertVC.addAction(cancelAction)
        
        present(alertVC, animated: true)
    }
    
    func saveToLocal(indexPath: IndexPath) {
        let fileManager = FileManager.default
        guard let downloadFolderURL = fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
            return
        }
        let subFolderURL = downloadFolderURL.appendingPathComponent("Your-Images")
        print(subFolderURL.path)
        do{
            try fileManager.createDirectory(at: subFolderURL, withIntermediateDirectories: true)
        }
        catch {
            print(error)
        }
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let timeStamp = dateFormatter.string(from: date)
        let fileURL = subFolderURL.appendingPathComponent("image-\(timeStamp).jpg")
        guard let imageData = imageList[indexPath.row].jpegData(compressionQuality: 1.0) else {
            return
        }
        fileManager.createFile(atPath: fileURL.path, contents: imageData)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == Constants.gotoDet) {
            if let second = segue.destination as? SecondVC {
                second.loadViewIfNeeded()
                second.showImg.image = UIImage(named: ImgList.list[idxPath.row].imgName)
            }
        }
    }
    
}

extension FirstVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return ImgList.list.count
        return imageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.collectionNibCell, for: indexPath) as! customCVCell
                
//        cell.showImg.image = UIImage(named: ImgList.list[indexPath.row].imgName)
        cell.showImg.image = imageList[indexPath.row]
        
        return cell
        
    }
}

