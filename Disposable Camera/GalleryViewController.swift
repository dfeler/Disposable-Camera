//
//  GalleryViewController.swift
//  Disposable Camera
//
//  Created by Daniel Feler

import UIKit

class GalleryViewController: UIViewController {
    
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    let imageSave = SaveImages()
    var urls:[URL] = [URL]()
    var index = -1
    var passedContentOffset = IndexPath()


    override func viewDidLoad() {
        
        super.viewDidLoad()
        

        galleryCollectionView.delegate=self
        galleryCollectionView.dataSource=self
        
        galleryCollectionView.backgroundColor=UIColor.white
        self.view.addSubview(galleryCollectionView)
        
        galleryCollectionView.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.RawValue(UInt8(UIView.AutoresizingMask.flexibleWidth.rawValue) | UInt8(UIView.AutoresizingMask.flexibleHeight.rawValue)))
        

        // Do any additional setup after loading the view.
    }
    
    override var prefersStatusBarHidden: Bool
       {
               return true
       }
     override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            return .landscape
   
        }
    
    override func viewWillDisappear(_ animated: Bool) {
           // AppUtility.lockOrientation(.landscapeLeft)

    }
    
    override func viewWillAppear(_ animated: Bool) {
      // AppUtility.lockOrientation(.all)

        urls = imageSave.getListOfImage()
        self.sortGallery()
        
        
    }
    
    override var shouldAutorotate: Bool
       {
           return true
       }
    
    
    func sortGallery()
    {
        print(urls)
        
        let ready = urls.sorted(by: { $0.deletingPathExtension().lastPathComponent.compare($1.deletingPathExtension().lastPathComponent) == .orderedAscending })
        // For Descending use .orderedDescending
        print(ready)
        urls  = ready
        
        self.galleryCollectionView.reloadData()

       
    
    }

    
    @IBAction func goBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillLayoutSubviews() {
          super.viewWillLayoutSubviews()
          galleryCollectionView.collectionViewLayout.invalidateLayout()
      }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "view_image"
        {
            let vc = segue.destination as! ViewImageViewController
            vc.urls = self.urls
           
            vc.indexOfDelete = self.index
            
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
extension GalleryViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if urls.count ==  0
        {
            collectionView.setEmptyView(title: "No Photos ", message: "Snap Some Photos and Come Back to See Them")
        }
        else
        {
            collectionView.restore()
        }
        return urls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"Cell", for: indexPath) as! GalleryCollectionViewCell
        
        let image = UIImage(contentsOfFile: urls[indexPath.row].path)
        
        
        cell.galleryImageView.image = image
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        
        
        let width = collectionView.frame.width
          
               if DeviceInfo.Orientation.isPortrait {
                   return CGSize(width: width/4 - 1, height: width/4 - 1)
               } else {
                   return CGSize(width: width/6 - 1, height: width/6 - 1)
               }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        index = indexPath.row
        passedContentOffset = indexPath
        self.performSegue(withIdentifier: "view_image", sender: nil)
    }
    
    
}

extension UICollectionView {
    func setEmptyView(title: String, message: String) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        messageLabel.textColor = UIColor.lightGray
        messageLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        // The only tricky part is here:
        self.backgroundView = emptyView
    }
    func restore() {
        self.backgroundView = nil
    }
}

