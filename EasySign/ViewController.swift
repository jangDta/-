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
import FBSDKCoreKit
import FBSDKLoginKit


class ViewController: UIViewController {

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var birthLabel: UILabel!
    @IBOutlet weak var facebookBtn: FBSDKLoginButton!
    @IBOutlet weak var profileImageView: UIImageView!
    
    let naverinstance = NaverThirdPartyLoginConnection.getSharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        
        if FBSDKAccessToken.currentAccessTokenIsActive(){
            //fetchProfile()
        }
        
    }
    
    func fetchProfile(){
        let accessToken = FBSDKAccessToken.current()
        let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email,id,name,picture.type(large)"], tokenString: accessToken?.tokenString, version: nil, httpMethod: "GET")
        print("여기까지0")
        req?.start(completionHandler: { (connection, result, error) in
            
            
            print("여기까지1")

            if error==nil{
                print("여기까지2")

                print(result)
                
                guard let Info = result as? [String: Any] else { return }
                guard let email = Info["id"] as? String else {return}
                guard let name = Info["name"] as? String else {return}
                self.emailLabel.text = email
                self.nameLabel.text = name
                
                if let imageURL = ((Info["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String{
                    //Download image from imageURL
                    let url = URL(string: imageURL)
                    let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    self.profileImageView.image = UIImage(data: data!)
                    
                }
                
            }else{
                print(error?.localizedDescription)
            }
        })
        
    }

    @IBAction func goNaver(_ sender: Any) {
        naverinstance?.delegate = self
        naverinstance?.requestThirdPartyLogin()
    }
    
    @IBAction func goFacebook(_ sender: Any) {
        facebookBtn.delegate = self
        
        facebookBtn.readPermissions = ["public_profile","email","user_friends"]
        
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
        
        
        let authorization = "\(tokenType) \(accessToken)"
        Alamofire.request("https://openapi.naver.com/v1/nid/me", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization" : authorization]).responseJSON { (response) in
            guard let result = response.result.value as? [String: Any] else {return}
            guard let object = result["response"] as? [String: Any] else {return}
            guard let birthday = object["birthday"] as? String else {return}
            guard let name = object["name"] as? String else {return}
            guard let email = object["email"] as? String else {return}
            
            self.birthLabel.text = birthday
            self.emailLabel.text = email
            self.nameLabel.text = name
            print(result)
        }
    }
}

extension ViewController : FBSDKLoginButtonDelegate{
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if error != nil{
            print(error.localizedDescription)
        }else if result.isCancelled{
            print("페이스북 로그인 취소")
        }else{
            // login success
            fetchProfile()
            print(result)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        self.emailLabel.text = "이메일"
        self.nameLabel.text = "이름"
        self.birthLabel.text = "생일"
        self.profileImageView.image = #imageLiteral(resourceName: "swift")
    }
    
    
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
