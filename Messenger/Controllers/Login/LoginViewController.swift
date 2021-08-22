//
//  LoginViewController.swift
//  Messenger
//
//  Created by haju Kim on 2021/08/19.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

class LoginViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
       let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "이메일 주소....."
        field.leftView = UIView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: 5,
                                              height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "비밀번호....."
        field.leftView = UIView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: 5,
                                              height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        //->비밀번호 보안 설정 안한 이유:자판 에러가 나서 보류
//        field.isSecureTextEntry = true
        return field
    }()
    //->정보를 입력하면 전송하는 버튼
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    //->페이스북 로그인 버튼 설정. 나중에 ui버튼을 꾸민다음에 페이스북 로그인 버튼을 적용해서 통일감을 줘야 할거같음.
    //->추가 완료!
    private let facebookLoginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.layer.cornerRadius = 12
        button.setTitleColor(.white, for: .normal)
        button.permissions = ["email","public_profile"]
        button.layer.masksToBounds = true //->마스크들을 곱하여 최종값을 만들어주는 기능. 이거 없으면 안됨.
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    private let googleLoginButton = GIDSignInButton()
    
    private var loginObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //->메모리 절약을 위해서 추가한 코드
        loginObserver = NotificationCenter.default.addObserver(forName: Notification.Name.didLoginNotification, object: nil, queue: .main, using: { [weak self]_ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        title = "Log in"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "회원가입",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        loginButton.addTarget(self,
                              action: #selector(loginButtonTapped),
                              for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        facebookLoginButton.delegate = self
        
        //서브뷰를 추가로 보여주기
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        
        //->페이스북 로그인 버튼 설정
        scrollView.addSubview(facebookLoginButton)
        //->구글 로그인 버튼 설정
        scrollView.addSubview(googleLoginButton)
    }
    //->로그인 옵저버 초기화
    deinit {
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    //->로그인 화면 구성,디자인
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 20,
                                 width: size,
                                 height: size)
        
        emailField.frame = CGRect(x: 30,
                                  y: imageView.bottom+10,
                                  width: scrollView.width - 60,
                                  height: 52)
        
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom+10,
                                     width: scrollView.width - 60,
                                     height: 52)
        loginButton.frame = CGRect(x: 30,
                                   y: passwordField.bottom + 10,
                                   width: scrollView.width - 60,
                                   height: 52)
        
        //->28로 줄인이유: xcode 콘솔에서 레이아웃간의 충돌이 일어난다고 길이를 맞추라고 지시해서. 찾아보니까 당장은 문제가 없어 보일지 몰라도 실제로 상용화 되었을때 레이아웃으로 인한 버그가 생기는 원인이라고 해서 결국 줄임
   
        facebookLoginButton.frame = CGRect(x: 30,
                                           y: loginButton.bottom + 10,
                                           width: scrollView.width - 60,
                                           height: 28)
        
        googleLoginButton.frame = CGRect(x: 30,
                                         y: facebookLoginButton.bottom+10,
                                         width: scrollView.width-60,
                                         height: 52)
    }
    //->버튼을 눌렀을때 처리, 및 전달 그리고 조건을 서술
    @objc private func loginButtonTapped() {
        
        //->키패드를 열고 닫을수 있는 기능 추가
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserLoginError()
            return
        }
        //->파이어 베이스 로그인 처리 담당
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            guard let result = authResult, error == nil else {
                print("해당 유저 로그인이 실패했습니다. \(email)")
                return
            }
            let user = result.user
            print("로그인한 유저: \(user)")
            //->약한 레퍼런스 참조로 해놓고 왜 굳이 다시 스토롱 셀프를 만드는지 이해 불가
            // 나중에 찾아봐야겠음
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    //->로그인할때 모든 정보를 입력하지 않았을때의 에러 처리
    func alertUserLoginError() {
        let alert = UIAlertController(title: "에러발생!",
                                      message: "로그인할때 모든 정보를 입력해주세요!",
                                      preferredStyle: .alert)
        //->알림처리
        alert.addAction(UIAlertAction(title: "아이디, 비번을 다시 확인해주세요.",
                                      style: .cancel,
                                      handler: nil))
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister() {
       let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
}
//->이메일 텍스트 필드와 패스워드 텍스트 필드 확장
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }else if textField == passwordField{
            loginButtonTapped()
        }
        return true
    }
}
extension LoginViewController: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        //->이 앱에서는 굳이 로그아웃기능을 확장할 필요가 없다. 그래서 그냥 냅두셈.
    }
    //->페이스북 로그인 버튼 기능 확장
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("페이스북 로그인에 실패했습니다.")
            return
        }
        //->데이터 베이스에 페이스북 로그인 정보를 저장하기 위한것.
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters: ["fields": "email, name"],
                                                         tokenString: token,
                                                         version: nil,
                                                         httpMethod: .get)
        //->문법이 달라진 부분이 있어서 이부분은 조정.
        facebookRequest.start(completion: { _, result, error in
            guard let result = result as? [String: Any], error == nil else {
                print("페이스북 그래프 요청 실패")
                return
            }
            guard let userName = result["name"] as? String,
                  let email = result["email"] as? String else {
                print("이메일과 이름을 페이스북에서 가져오는데 실패했습니다. ")
                return
            }
            let nameComponents = userName.components(separatedBy: " ")
            guard nameComponents.count == 2 else {
               return
            }
            let firstName = nameComponents[0]
            let lastName = nameComponents[1]
            
            //->데이터 베이스에 삽입 처리
            DatabaseManager.shared.userExists(with: email, completion: { exists in
                if !exists {
                    DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName,
                                                                        lastName: lastName,
                                                                        emailAddress: email))
                }
            })
            
            //->이 단계 로그인을 하기 위해서는: 파이어 베이스 콘솔쪽으로 가서 설정해줘야 한다. 파이어베이스에서 자격 증명을 얻는다
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authResult, error in
                guard let strongSelf = self else {
                    return
                }
                guard authResult != nil, error == nil else {
                    if let error = error {
                        print("페이스북 로그인에 실패했습니다. 아마 인증단계가 필요한거 같습니다. -\(error)")
                    }
                    return
                }
                print("페이스북 로그인에 성공했습니다!")
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
           })
        })
    }
}
