//
//  ViewController.swift
//  EasySign
//
//  Created by 장한솔 on 2018. 7. 25..
//  Copyright © 2018년 장한솔. All rights reserved.
//

import UIKit
import Alamofire
import NaverThirdPartyLogin

class ViewController: UIViewController {

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var birthLabel: UILabel!
    
    let naverinstance = NaverThirdPartyLoginConnection.getSharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func goNaver(_ sender: Any) {
        naverinstance?.delegate = self
        naverinstance?.requestThirdPartyLogin()
    }
    
    @IBAction func logout(_ sender: Any) {
        naverinstance?.requestDeleteToken()
        emailLabel.text = "이메일"
        nameLabel.text = "이름"
        birthLabel.text = "생일"
    }
    
}

extension ViewController: NaverThirdPartyLoginConnectionDelegate{
    // ---- 3
    func oauth20ConnectionDidOpenInAppBrowser(forOAuth request: URLRequest!) {
        let naverSignInViewController = NLoginThirdPartyOAuth20InAppBrowserViewController(request: request)!
        present(naverSignInViewController, animated: true, completion: nil)
    }
    // ---- 4
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        print("Success oauth20ConnectionDidFinishRequestACTokenWithAuthCode")
        getNaverEmailFromURL()
//        logoutBtn.isHidden = false
//        loginBtn.isHidden = true
    }
    // ---- 5
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        print("Success oauth20ConnectionDidFinishRequestACTokenWithRefreshToken")
        getNaverEmailFromURL()
//        logoutBtn.isHidden = false
//        loginBtn.isHidden = true
    }
    // ---- 6
    func oauth20ConnectionDidFinishDeleteToken() {
        
    }
    // ---- 7
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        print(error.localizedDescription)
        print(error)
    }
    // ---- 8
    func getNaverEmailFromURL(){
        guard let loginConn = NaverThirdPartyLoginConnection.getSharedInstance() else {return}
        guard let tokenType = loginConn.tokenType else {return}
        guard let accessToken = loginConn.accessToken else {return}
        
        print("여기까지0")
        
        let authorization = "\(tokenType) \(accessToken)"
        Alamofire.request("https://openapi.naver.com/v1/nid/me", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization" : authorization]).responseJSON { (response) in
            guard let result = response.result.value as? [String: Any] else {return}
            guard let object = result["response"] as? [String: Any] else {return}
            guard let birthday = object["birthday"] as? String else {return}
            guard let name = object["name"] as? String else {return}
            guard let email = object["email"] as? String else {return}
            
            print("여기까지1")
            
            self.birthLabel.text = birthday
            self.emailLabel.text = email
            self.nameLabel.text = name
            print(result)
        }
    }
}

