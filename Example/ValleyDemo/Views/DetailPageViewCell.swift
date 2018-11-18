//
//  DetailPageViewCell.swift
//  ValleyDemo
//
//  Created by Jahid Hassan on 11/18/18.
//  Copyright © 2018 Jahid Hassan. All rights reserved.
//

import UIKit

private let cellIdentifier = "tableCellIdentifier"

class DetailTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.textLabel?.font = UIFont.systemFont(ofSize: 13)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageView: UIImageView = self.imageView!
        imageView.frame = CGRect.zero
        if (imageView.image != nil) {
            let imageHeight = imageView.image!.size.height * screenWidth / imageView.image!.size.width
            imageView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: imageHeight)
        }
    }
}

class DetailPageViewCell : UICollectionViewCell {
    var pullAction : ((_ offset : CGPoint) -> Void)?
    var tappedAction : (() -> Void)?
    private let tableView = UITableView(frame: screenBounds, style: UITableView.Style.plain)
    
    var dataModel: PostDataModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        tableView.tableFooterView = UIView()
        contentView.addSubview(tableView)
        
        tableView.register(DetailTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.reloadData()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.lightGray
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView : UIScrollView){
        if scrollView.contentOffset.y < navigationHeight{
            pullAction?(scrollView.contentOffset)
        }
    }
}

extension DetailPageViewCell: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! DetailTableViewCell
        cell.imageView?.image = nil
        cell.textLabel?.text = nil
        
        if indexPath.row == 0, let dataModel = dataModel {
            cell.imageView?.setImage(from: dataModel.urls.regular, placeholder: UIImage(named: "piture"), completion: { _, _ in
                cell.setNeedsLayout()
            })
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var cellHeight : CGFloat = navigationHeight
        
        if indexPath.row == 0, let dataModel = dataModel {
            cellHeight = CGFloat(dataModel.height) * screenWidth / CGFloat(dataModel.width)
        }
        
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tappedAction?()
    }
}
