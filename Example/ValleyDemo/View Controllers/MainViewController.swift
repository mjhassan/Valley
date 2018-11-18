//
//  ViewController.swift
//  ValleyDemo
//
//  Created by Jahid Hassan on 11/17/18.
//  Copyright © 2018 Jahid Hassan. All rights reserved.
//

import UIKit
import Valley
import os.log

class MainViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private let cellIdentifier = "PinCollectionViewCell"
    private let urlString = "http://pastebin.com/raw/wgkJgazE"
    private let contentHeight: CGFloat = 80
    
    private var models: [PostDataModel]? = nil {
        didSet {
            collectionView.reloadData()
        }
    }
    private var cellWidth: CGFloat = 0
    private let navigationDelegate = NavigationControllerDelegate()
    private var refresher: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.delegate = navigationDelegate
        
        collectionView.contentInset = UIEdgeInsets(top: 23, left: 10, bottom: 10, right: 10)
        // Set the PinterestLayout delegate
        if let layout = collectionView.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
        }
        
        addPullToRefresh()
        registerNibs()
        calculateCellWidth()
        loadData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let layout = self?.collectionView.collectionViewLayout as? PinterestLayout else {
                return
            }
            
            self?.collectionView.collectionViewLayout.invalidateLayout()
            
        }, completion: nil)
    }
}

// MARK: - private methods
extension MainViewController {
    private func addPullToRefresh() {
        collectionView!.alwaysBounceVertical = true
        refresher = UIRefreshControl()
        refresher.tintColor = .orange
        refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        collectionView.addSubview(refresher)
    }
    
    private func registerNibs() {
        let cellNib = UINib(nibName: cellIdentifier, bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: cellIdentifier)
    }
    
    @objc
    private func loadData() {
        Valley.shared.fetchData(from: urlString, forceCaching: true) { [weak self] (data, error) in
            self?.refresher.endRefreshing()
            
            guard let data = data else {
                return
            }
            
            do {
                let models = try JSONDecoder().decode([PostDataModel].self, from: data)
                self?.models = models
            }
            catch let error {
                let log = "Data mapping failed. ERROR: \(error)"
                if #available(iOS 12.0, *) {
                    os_log("%@", type: .debug, log)
                } else {
                    print("\(log)")
                }
            }
        }
    }
    
    private func calculateCellWidth() {
        guard let collectionView = collectionView else {
            cellWidth = 0
            return
        }
        
        let insets = collectionView.contentInset
        cellWidth = (collectionView.bounds.width - (insets.left + insets.right)) / 2
    }
    
    private func detailViewControllerLayout () -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        let itemSize  = self.navigationController!.isNavigationBarHidden ?
            CGSize(width: screenWidth, height: screenHeight + 20) : CGSize(width: screenWidth, height: screenHeight - navigationHeaderAndStatusbarHeight)
        flowLayout.itemSize = itemSize
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .horizontal
        
        return flowLayout
    }
}

// MARK: - Collection view data source and delegate
extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let pinCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PinCollectionViewCell
        pinCell.dataModel = models?[indexPath.item]
        
        return pinCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pageViewController = DetailsViewController(collectionViewLayout: detailViewControllerLayout(), currentIndexPath: indexPath)
        pageViewController.dataModels = models
        collectionView.setToIndexPath(indexPath)
        
        navigationController!.pushViewController(pageViewController, animated: true)
    }
}

// MARK: - PinterestLayoutDelegate
extension MainViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        guard let height = models?[indexPath.item].height,
        let width = models?[indexPath.item].width else {
            return cellWidth
        }
        
        return CGFloat(height) * cellWidth / CGFloat(width) + contentHeight
    }
}

// MARK: - Transition delegates
extension MainViewController: ValleyTransitionProtocol, ValleyWaterFallViewControllerProtocol {
    func transitionCollectionView() -> UICollectionView! {
        return collectionView
    }
    
    func viewWillAppearWithPageIndex(_ pageIndex: NSInteger) {
        var position: UICollectionView.ScrollPosition = UICollectionView.ScrollPosition.centeredHorizontally.intersection(.centeredVertically)
        
        guard let model = models?[pageIndex] else { return }
        
        let imageHeight = CGFloat(model.height) * gridWidth / CGFloat(model.width)
        if imageHeight > maxImageHeight {
            position = .top
        }
        
        let currentIndexPath = IndexPath(row: pageIndex, section: 0)
        collectionView?.setToIndexPath(currentIndexPath)
        if pageIndex < 2 {
            collectionView?.setContentOffset(CGPoint.zero, animated: false)
        } else {
            collectionView?.scrollToItem(at: currentIndexPath, at: position, animated: false)
        }
    }
}
