//
//  ViewController.swift
//  PhotoGrid
//
//  Created by Astha Ameta on 8/19/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imagesCollectionView: UICollectionView!
    
    var imageVM: ImageViewModel!
    var img: UIImage!
    var selectedIndexPath: IndexPath!
    var currentLeftSafeAreaInset  : CGFloat = 0.0
    var currentRightSafeAreaInset : CGFloat = 0.0
    var photo: [UIImage] = []
    var dataModel = [DataModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nibName = UINib(nibName: "ImageCollectionViewCell", bundle:nil)
        imagesCollectionView.register(nibName, forCellWithReuseIdentifier: "ImageCollectionViewCell")
        
        imageVM = ImageViewModel()
        imageVM.performRequest()

        downloadPhoto()
    }

    override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11, *) {
            self.currentLeftSafeAreaInset = self.view.safeAreaInsets.left
            self.currentRightSafeAreaInset = self.view.safeAreaInsets.right
        }
    }
    
    override func viewWillLayoutSubviews() {
        if #available(iOS 11, *) {
            
            self.view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: self.view.bounds.size)
            self.imagesCollectionView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: self.view.bounds.size)
            
            self.imagesCollectionView.contentInsetAdjustmentBehavior = .never
          //  let statusBarHeight : CGFloat = UIApplication.shared.statusBarFrame.height
            let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
            let navBarHeight : CGFloat = navigationController?.navigationBar.frame.height ?? 0
            self.edgesForExtendedLayout = .all
            let tabBarHeight = self.tabBarController?.tabBar.frame.height ?? 0
            
            if UIDevice.current.orientation.isLandscape {
                self.imagesCollectionView.contentInset = UIEdgeInsets(top: (navBarHeight) + statusBarHeight, left: self.currentLeftSafeAreaInset, bottom: tabBarHeight, right: self.currentRightSafeAreaInset)
            }
            else {
                self.imagesCollectionView.contentInset = UIEdgeInsets(top: (navBarHeight) + statusBarHeight, left: 0.0, bottom: tabBarHeight, right: 0.0)
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if #available(iOS 11, *) {
            //Do nothing
        }
        else {

            if self.viewIfLoaded?.window != nil {
                
                coordinator.animate(alongsideTransition: { _ in

                    self.view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
                    self.imagesCollectionView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
                    
                }, completion: { _ in
                    
                    self.imagesCollectionView.collectionViewLayout.invalidateLayout()
                    
                })
                
            }
            //Otherwise, do not animate the transition
            else {
                
                self.view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
                self.imagesCollectionView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
                self.imagesCollectionView.collectionViewLayout.invalidateLayout()
                
            }
        }
        
    }
    
    func downloadPhoto(){
        DispatchQueue.global().async {
            self.photo.removeAll()

            for i in 0..<self.imageVM.numberOfImages() {
                guard let url = URL(string: self.imageVM.model[i].url) else {
                    continue
                }

                let group = DispatchGroup()
                group.enter()
                URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
                    print(response?.suggestedFilename ?? url.lastPathComponent)

                    if let imgData = data, let image = UIImage(data: imgData) {
                        DispatchQueue.main.async() {
                            self.photo.append(image)
                            self.imagesCollectionView.reloadData()
                        }
                    } else if let error = error {
                        print(error)
                    }

                    group.leave()
                }).resume()

                group.wait()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPhotoPageView" {
            let nav = self.navigationController
            let vc = segue.destination as! ZoomImageViewController
            nav?.delegate = vc.transitionController
            vc.transitionController.fromDelegate = self
            vc.transitionController.toDelegate = vc
            vc.delegate = self
            vc.currentIndex = self.selectedIndexPath.row
            vc.photos = self.photo
        }
    }
    
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let itemWidth = (screenWidth)/3
        let itemHeight = (screenWidth)/3
        return CGSize(width: itemWidth, height: itemHeight)

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageVM.numberOfImages()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imagesCollectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
        
        let imageString = imageVM.model[indexPath.row].url
        cell.gridImageView.contentMode = .scaleAspectFill
        cell.gridImageView.load(urlString: imageString)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        self.performSegue(withIdentifier: "ShowPhotoPageView", sender: self)
    }
    
    func getImageViewFromCollectionViewCell(for selectedIndexPath: IndexPath) -> UIImageView {
        let visibleCells = self.imagesCollectionView.indexPathsForVisibleItems
        
        if !visibleCells.contains(self.selectedIndexPath) {
            self.imagesCollectionView.scrollToItem(at: self.selectedIndexPath, at: .centeredVertically, animated: false)
            
            self.imagesCollectionView.reloadItems(at: self.imagesCollectionView.indexPathsForVisibleItems)
            self.imagesCollectionView.layoutIfNeeded()
            
            guard let guardedCell = (self.imagesCollectionView.cellForItem(at: self.selectedIndexPath) as? ImageCollectionViewCell) else {
                return UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0))
            }
            return guardedCell.gridImageView
        }
        else {
            
            guard let guardedCell = self.imagesCollectionView.cellForItem(at: self.selectedIndexPath) as? ImageCollectionViewCell else {
                return UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0))
            }
            return guardedCell.gridImageView
        }
        
    }
    
    func getFrameFromCollectionViewCell(for selectedIndexPath: IndexPath) -> CGRect {
        let visibleCells = self.imagesCollectionView.indexPathsForVisibleItems
        
        if !visibleCells.contains(self.selectedIndexPath) {
            
            self.imagesCollectionView.scrollToItem(at: self.selectedIndexPath, at: .centeredVertically, animated: false)
            
            self.imagesCollectionView.reloadItems(at: self.imagesCollectionView.indexPathsForVisibleItems)
            self.imagesCollectionView.layoutIfNeeded()
            
            guard let guardedCell = (self.imagesCollectionView.cellForItem(at: self.selectedIndexPath) as? ImageCollectionViewCell) else {
                return CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0)
            }
            
            return guardedCell.frame
        }
        else {
            guard let guardedCell = (self.imagesCollectionView.cellForItem(at: self.selectedIndexPath) as? ImageCollectionViewCell) else {
                return CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0)
            }
            return guardedCell.frame
        }
    }
    
}

extension ViewController: ZoomImageViewControllerDelegate {
 
    func containerViewController(_ containerViewController: ZoomImageViewController, indexDidUpdate currentIndex: Int) {
        self.selectedIndexPath = IndexPath(row: currentIndex, section: 0)
        self.imagesCollectionView.scrollToItem(at: self.selectedIndexPath, at: .centeredVertically, animated: false)
    }
}

extension ViewController: ZoomAnimatorDelegate {
    
    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {
        
    }
    
    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
        let cell = self.imagesCollectionView.cellForItem(at: self.selectedIndexPath) as! ImageCollectionViewCell
        let cellFrame = self.imagesCollectionView.convert(cell.frame, to: self.view)
        
        if cellFrame.minY < self.imagesCollectionView.contentInset.top {
            self.imagesCollectionView.scrollToItem(at: self.selectedIndexPath, at: .top, animated: false)
        } else if cellFrame.maxY > self.view.frame.height - self.imagesCollectionView.contentInset.bottom {
            self.imagesCollectionView.scrollToItem(at: self.selectedIndexPath, at: .bottom, animated: false)
        }
    }
    
    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
        let referenceImageView = getImageViewFromCollectionViewCell(for: self.selectedIndexPath)
        return referenceImageView
    }
    
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect? {
        self.view.layoutIfNeeded()
        self.imagesCollectionView.layoutIfNeeded()
        let unconvertedFrame = getFrameFromCollectionViewCell(for: self.selectedIndexPath)
        let cellFrame = self.imagesCollectionView.convert(unconvertedFrame, to: self.view)
        
        if cellFrame.minY < self.imagesCollectionView.contentInset.top {
            return CGRect(x: cellFrame.minX, y: self.imagesCollectionView.contentInset.top, width: cellFrame.width, height: cellFrame.height - (self.imagesCollectionView.contentInset.top - cellFrame.minY))
        }
        
        return cellFrame
    }
}

var imageCache = NSCache<AnyObject, AnyObject>()
extension UIImageView {
    func load(urlString: String) {
        
        if let image = imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.image = image
            return
        }
        
        guard let url = URL(string: urlString) else { return }
        
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url){
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        imageCache.setObject(image, forKey: urlString as NSString)
                        self?.image = image
                    }
                }
            }
        }
    }
}

