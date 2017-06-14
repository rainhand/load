//
//  HomeViewController.swift
//  xinwoxing
//
//  Created by 郭超 on 2017/6/3.
//  Copyright © 2017年 郭超. All rights reserved.
//

import UIKit
class HomeViewController: BaseViewController , UITableViewDelegate , UITableViewDataSource{
    
    var RotationView: UIImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(tableView)
        
        //注册cell
        
        tableView.register(HeaderTableViewCell.classForCoder(), forCellReuseIdentifier: "first")
       
        //网络请求
        loadData()
        
    }
    override func loadData() {
        
        let dict:NSDictionary = ["":""]
        
        HttpsRequest.shareRequest().startRequest(url: "", paraments: dict, requestType: RequestType.POST_REQUEST, successBack: { (dict) in
            print(dict)
            
        }, faildBack: { (error) in
             print(error)
        }) { (progress) in
            print(progress.completedUnitCount/progress.totalUnitCount)
        }
        
    }
    
//懒加载
    
    lazy var tableView:UITableView = {
        let tbv:UITableView = UITableView(frame: self.view.bounds)
        tbv.delegate = self
        tbv.dataSource = self
        return tbv
    }()
    
    lazy var firstHeaderView:UIView = {
        let headerView = UIView(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: 49))
        let titleArr:[String] = ["职位类型", "薪资范围", "工作城市"]
        for i in 0 ..< 3{
            let selectBut = UIButton.init(type: UIButtonType.custom)
            selectBut.setTitle(titleArr[i], for: UIControlState.normal)
            selectBut.frame = CGRect.init(x: screenWidth/3 * CGFloat(i), y: 0, width: screenWidth/3, height: 49)
            selectBut.setTitleColor(UIColor.black, for: UIControlState.normal)
            selectBut.tag = 100 + i
            selectBut.addTarget(self, action: #selector(zhiwei(button:)) , for: UIControlEvents.touchDown)
            headerView .addSubview(selectBut)
            
            let signView:UIImageView = UIImageView(frame: CGRect.init(x: screenWidth/3 * CGFloat(i + 1) - 20 , y: 20, width: 20, height: 20))
            signView.image = UIImage.init(named: "Rectangle 9 Copy 13")
            headerView.addSubview(signView)
            signView.tag = 200 + i
        }
        return headerView
    }()

    //选择按钮点击
    func zhiwei(button:UIButton) {
        switch button.tag {
        case 100:
            print("aaaa")
            let rotionView = button.superview?.viewWithTag(200)
            UIView.animate(withDuration: 0.2) { () -> Void in
                //指定旋转角度是180°
                rotionView?.transform = (rotionView?.transform)!.rotated(by: CGFloat(Double.pi))
            }
        case 101:
            print("bbb")
        case 102:
            print("cccc")
        default:
            print("oooooo")
        }
    }
}



extension HomeViewController
{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section==0 {
            
            return 1
        }
        return 30
    }
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 203
        }
        return 150
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {

            return 49
        }
        
        return 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            
            return firstHeaderView
        }
        
        return nil
    
    }
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let firstCell:HeaderTableViewCell = tableView.dequeueReusableCell(withIdentifier: "first", for: indexPath) as! HeaderTableViewCell
            return firstCell
        }
        
        var cell:CompanyTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "bbb") as? CompanyTableViewCell
        
        if cell  == nil {
            cell = CompanyTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "bbb")
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let baseVC:BaseViewController = BaseViewController()
        self.navigationController?.pushViewController(baseVC, animated: true)
        
        
    }
    
   
}
