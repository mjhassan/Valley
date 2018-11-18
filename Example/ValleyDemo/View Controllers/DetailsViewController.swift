//
//  DetailsViewController.swift
//  ValleyDemo
//
//  Created by Jahid Hassan on 11/18/18.
//  Copyright © 2018 Jahid Hassan. All rights reserved.
//

import UIKit

private let reuseIdentifier = "DetailPageViewCell"

class DetailsViewController: UICollectionViewController {

    var dataModels: [PostDataModel]? = []
    var pullOffset: CGPoint = .zero
    
    init(collectionViewLayout layout: UICollectionViewLayout!, currentIndexPath indexPath: IndexPath){
        super.init(collectionViewLayout:layout)
        
        let collectionView: UICollectionView = self.collectionView!
        collectionView.isPagingEnabled = true
        collectionView.setToIndexPath(indexPath)
        collectionView.performBatchUpdates({collectionView.reloadData()}, completion: { finished in
            if finished {
                collectionView.scrollToItem(at: indexPath,at:.centeredHorizontally, animated: false)
            }
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        collectionView.register(DetailPageViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.collectionView.collectionViewLayout.invalidateLayout()
            }, completion: nil)
    }
    
    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataModels?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionCell: DetailPageViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DetailPageViewCell
        collectionCell.dataModel = dataModels?[indexPath.item]
        collectionCell.pullAction = { offset in
            self.pullOffset = offset
            self.navigationController!.popViewController(animated: true)
        }
        collectionCell.setNeedsLayout()
        return collectionCell
    }

}

extension DetailsViewController: ValleyTransitionProtocol, ValleyDetailViewControllerProtocol {
    func transitionCollectionView() -> UICollectionView! {
        return collectionView
    }
    
    func pageViewCellScrollViewContentOffset() -> CGPoint {
        return pullOffset
    }
}
