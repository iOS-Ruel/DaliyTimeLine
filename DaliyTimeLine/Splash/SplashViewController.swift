//
//  SplashViewController.swift
//  DaliyTimeLine
//
//  Created by Chung Wussup on 1/19/24.
//

import UIKit
import SnapKit
import Firebase

class SplashViewController: UIViewController {
    //TODO: - 로그인 체크를 해당 controller에서 해야함 -> 로그인이 안되었을때 로그인 페이지로 로그인이 되어있는 경우 메인 탭바로 이동
    
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "logoImage.png")
        iv.tintColor = .black
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "OTSBAggroM", size: 18)
        label.text = "Daily TimeLine"
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        counfigureUI()
       
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            if let _ = Auth.auth().currentUser {
                if UserDefaults.standard.string(forKey: "LoginSecret") != nil {
                    let secertView = SecretSettingViewController(isLogin: true)
                    secertView.modalPresentationStyle = .fullScreen
                    secertView.delegate = self
                    self.present(secertView, animated: true)
                } else {
                    self.goToMain()
                }
            } else {
                let loginView = LoginViewController(viewModel: LoginViewModel())
                loginView.modalPresentationStyle = .fullScreen
                loginView.delegate = self
                self.present(loginView, animated: true)
            }
        }
    }
    
    func counfigureUI() {
        view.backgroundColor = .white
        [logoImageView].forEach { view.addSubview($0) }
        
        logoImageView.snp.makeConstraints { make in
            make.height.width.equalTo(180)
            make.centerX.centerY.equalTo(self.view)
        }
    }
    
}
extension SplashViewController: LoginDelegate, SecretSettingViewDelegate {
    func goToMain() {
        
        if let navigationController = self.navigationController {
            let viewControllerB = MainTabbarController() 
            navigationController.navigationBar.isHidden = true
            navigationController.pushViewController(viewControllerB, animated: false)
        }
    }
}
