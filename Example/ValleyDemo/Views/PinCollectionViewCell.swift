//
//  Cell.swift
//  AHPinterest
//
//  Created by Andy Hurricane on 3/26/17.
//  Copyright © 2017 AndyHurricane. All rights reserved.
//

import UIKit
import Valley

class PinCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var note: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var userName: UILabel!
//    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
//    @IBOutlet weak var noteHeightConstraint: NSLayoutConstraint!

    var dataModel: PostDataModel? {
        didSet{
            guard let dataModel = dataModel else { return }
            
            self.note.text = "lorem ipsum"
            self.userName.text = dataModel.user.username
            self.userAvatar.setImage(from: dataModel.user.profileImage.small, placeholder: UIImage(named: "picture"))
            self.imageView.setImage(from: dataModel.urls.thumb, placeholder: nil)
//            self.contentView.backgroundColor = UIColor(hexString: dataModel.color)
        }
    }
    
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                highLightAnimation()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.backgroundColor = UIColor(hexString: "EFEFF4")
        self.contentView.layer.cornerRadius = 8
        self.contentView.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.userName.text = nil
        self.imageView.image = nil
        self.note.text = nil
        self.userAvatar.image = nil
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return layoutAttributes
    }
    
//    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
//        if let attr = layoutAttributes as? AHPinLayoutAttributes{
//            imageViewHeightConstraint.constant = attr.imageHeight
//            noteHeightConstraint.constant = attr.noteHeight
//        }
//    }
}


extension PinCollectionViewCell {
    func highLightAnimation() {
        self.clipsToBounds = false
        
        let bgView = UIView(frame: self.bounds)
        bgView.layer.cornerRadius = 10
        bgView.backgroundColor = UIColor.lightGray
        bgView.alpha = 0.7
        self.insertSubview(bgView, belowSubview: contentView)
        self.contentView.layer.anchorPoint = .init(x: 0.5, y: 0.0)
        
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.0,
                       options: [],
                       animations: {
                        self.contentView.transform = .init(scaleX: 0.98, y: 0.98)
                        bgView.transform = .init(scaleX: 1.02, y: 1.02)
                        bgView.alpha = 0.4})
        
        UIView.animate(withDuration: 0.2,
                       delay: 0.35,
                       usingSpringWithDamping: 0.3,
                       initialSpringVelocity: 0.0,
                       options: [],
                       animations: {
                        self.contentView.transform = .identity
                        bgView.transform = .identity
                        bgView.alpha = 0.0
                       },
                       completion: { (_) in
                        self.clipsToBounds = true
                        bgView.removeFromSuperview()
                       })
    }
}

extension PinCollectionViewCell: ValleyTansitionWaterfallGridViewProtocol {
    func snapShotForTransition() -> UIView! {
        let snapShotView = UIImageView(image: imageView.image)
        snapShotView.frame = imageView.frame
        
        return snapShotView
    }
}
