//
//  ViewImageViewController.swift
//
//  Created by Daniel Feler

import UIKit

class ViewImageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    @IBOutlet weak var myCollectionView: UICollectionView!

    var imgArray = [UIImage]()
      var urls:[URL] = [URL]()
    var indexOfDelete = -1
        let imageSave = SaveImages()
       @IBOutlet weak var imageScrollView: ImageScrollView!
    var shareURL:URL?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        self.view.backgroundColor=UIColor.black
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing=0
        layout.minimumLineSpacing=0
        layout.scrollDirection = .horizontal
        
        myCollectionView.collectionViewLayout = layout
        myCollectionView.delegate=self
        myCollectionView.dataSource=self
        myCollectionView.register(ImagePreviewFullViewCell.self, forCellWithReuseIdentifier: "Cell")
        myCollectionView.isPagingEnabled = true
       
        
        
        
        myCollectionView.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.RawValue(UInt8(UIView.AutoresizingMask.flexibleWidth.rawValue) | UInt8(UIView.AutoresizingMask.flexibleHeight.rawValue)))
        
         
        
      
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImagePreviewFullViewCell
        
        let myImage = UIImage(contentsOfFile: urls[indexPath.row].path)!
        cell.imgView.image=myImage
        return cell
    }
    override func viewDidAppear(_ animated: Bool) {
     
        setImage()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
               return .landscape
      
           }
    
   
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        guard let flowLayout = myCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        flowLayout.itemSize = myCollectionView.frame.size
        
        flowLayout.invalidateLayout()
        
        myCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let offset = myCollectionView.contentOffset
        let width  = myCollectionView.bounds.size.width
        
        let index = round(offset.x / width)
        let newOffset = CGPoint(x: index * size.width, y: offset.y)
        
        myCollectionView.setContentOffset(newOffset, animated: false)
        
        coordinator.animate(alongsideTransition: { (context) in
            self.myCollectionView.reloadData()
            
            self.myCollectionView.setContentOffset(newOffset, animated: false)
        }, completion: nil)
    }
    
        @IBAction func goBack(_ sender: UIButton) {
            self.goBackTo()
        }
    
        func goBackTo()
        {
            self.dismiss(animated: true, completion: nil)
    
        }
    
    
        @IBAction func shareImage(_ sender: UIButton) {
            
    
       

            let image = UIImage(contentsOfFile: shareURL!.path)!

                   // set up activity view controller
            let imageToShare = [ image ]
                   let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
                   activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
    
                   // exclude some activity types from the list (optional)
                  // activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
    
                   // present the view controller
                   self.present(activityViewController, animated: true, completion: nil)
        }
    
    
        func showMessage(message: String)
        {
            let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    
        func deleteFile()
        {
    
    
            do {
                
                indexOfDelete = urls.firstIndex(of: shareURL!)!
                let url = urls[indexOfDelete]
                try FileManager.default.removeItem(at: url)
    
                urls = imageSave.getListOfImage()
                myCollectionView.reloadData()
                if urls.count > 0
                {
                    if indexOfDelete > 0
                {
                    indexOfDelete-=1
                }
    
                else if indexOfDelete == 0 && urls.count > 1
                {
                    //indexOfDelete+=1
                }
    
                    
                setImage()
                }
                else
                {
                    self.goBackTo()
                }
    
                }
            catch {
    
                showMessage(message: "Delete failed! Please try again")
                                       // No-op
                }
        }
    
  
    
        override var prefersStatusBarHidden: Bool
           {
                   return true
           }
    
        @IBAction func deletePhoto(_ sender: UIButton) {
            let alert = UIAlertController(title: "Delete Photo?", message: "Are you sure you want to delete this photo? This action cannot be undone.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                self.deleteFile()
    
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
    
            self.present(alert, animated: true, completion: nil)
            
            
            
        }
    
    
    func setImage()
        {
            
            
    
                    myCollectionView.scrollToItem(at: IndexPath(row: indexOfDelete, section: 0), at: .left, animated: true)
            shareURL = urls[indexOfDelete]

    
        }
    
    

}



class ImagePreviewFullViewCell: UICollectionViewCell, UIScrollViewDelegate {
    
    var scrollImg: UIScrollView!
    var imgView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        scrollImg = UIScrollView()
        scrollImg.delegate = self
        scrollImg.alwaysBounceVertical = false
        scrollImg.alwaysBounceHorizontal = false
        scrollImg.showsVerticalScrollIndicator = true
        scrollImg.flashScrollIndicators()
        
        scrollImg.minimumZoomScale = 1.0
        scrollImg.maximumZoomScale = 4.0
        
        let doubleTapGest = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapScrollView(recognizer:)))
        doubleTapGest.numberOfTapsRequired = 2
        scrollImg.addGestureRecognizer(doubleTapGest)
        
        self.addSubview(scrollImg)
        
        imgView = UIImageView()
        imgView.image = UIImage(named: "user3")
        scrollImg.addSubview(imgView!)
        imgView.contentMode = .scaleAspectFit
    }
    
    @objc func handleDoubleTapScrollView(recognizer: UITapGestureRecognizer) {
        if scrollImg.zoomScale == 1 {
            scrollImg.zoom(to: zoomRectForScale(scale: scrollImg.maximumZoomScale, center: recognizer.location(in: recognizer.view)), animated: true)
        } else {
            scrollImg.setZoomScale(1, animated: true)
        }
    }
    
    func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imgView.frame.size.height / scale
        zoomRect.size.width  = imgView.frame.size.width  / scale
        let newCenter = imgView.convert(center, from: scrollImg)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imgView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollImg.frame = self.bounds
        imgView.frame = self.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        scrollImg.setZoomScale(1, animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}





