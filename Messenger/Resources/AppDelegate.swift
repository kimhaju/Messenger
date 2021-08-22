//
//  AppDelegate.swift
//  Messenger
//
//  Created by haju Kim on 2021/08/19.
//

import UIKit
import Firebase
import FBSDKCoreKit
//->구글 로그인 구현: 최신 버전이 xcode 최신 버전에서만 지원되기 때문에 구글 로그인 버전을 다운시켜서 실행했다. 선택한 버전은 참고 자료가 많은 5.0.2 빅서가 안정되고 나서 최신버전을 설치할때는 새로운 버전으로 시도해보기.
import GoogleSignIn

//->페이스북 로그인 설정을 위해서 페이스북 로그인 페이지에서 가져왔음
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        FirebaseApp.configure()
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self
        
        return true
    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {

        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        return GIDSignIn.sharedInstance().handle(url)
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            if let error = error {
                print("구글 로그인에 실패했습니다. \(error)")
            }
            return
        }
        guard let user = user  else {
            return
        }
        print("구글로 로그인한 사용자 정보: \(user)")
        
        guard let email = user.profile.email,
              let firstName = user.profile.givenName,
              let lastName = user.profile.familyName else {
            return
        }
        //->데이터 베이스 가기전에 검증
        DatabaseManager.shared.userExists(with: email, completion: { exists in
            if !exists {
                //->데이터 베이스에 추가하는 로직
                DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName,
                                                                    lastName: lastName,
                                                                    emailAddress: email))
            }
        })
        
        guard let authentication = user.authentication else {
            print("해당하는 유저를 찾지 못했습니다.")
            return
        }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        FirebaseAuth.Auth.auth().signIn(with: credential, completion: { authResult, error in
            guard authResult != nil, error == nil else {
                print("구글 로그인에 실패했습니다.")
                return
            }
            print("구글 로그인에 성공했습니다.")
            NotificationCenter.default.post(name: .didLoginNotification, object: nil)
        })
    }
    //->사용자가 로그인했을때 사용되는 호출
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("구글과 유저 연동에 실패했습니다. ")
        
    }
}
    

