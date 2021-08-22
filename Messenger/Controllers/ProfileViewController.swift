//
//  ProfileViewController.swift
//  Messenger
//
//  Created by haju Kim on 2021/08/19.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

class ProfileViewController: UIViewController {
    
    //->프로파일 컨트롤러의 테이블뷰 설정
    @IBOutlet var tableView: UITableView!
    
    let data = ["Log Out"]

    override func viewDidLoad() {
        super.viewDidLoad()
        //->테이블 뷰에 데이터들을 보이게 설정
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
    }
}
//->로그아웃 기능을 추가하기 위해서 확장.
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    //->샐을 탭할경우 생기는 이벤트 추가(로그아웃)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //->사용자가 정말 로그아웃 할건지 다시한번 물어보는 알람기능(새로운 알람 기능을 추가 하고 싶을때 이 메서드 참조)
        let actionSheet = UIAlertController(title: "",
                                            message: "정말로 로그아웃 하시겠습니까?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Log out",
                                            style: .destructive,
                                            handler: { [weak self] _ in
                                                guard let strongSelf = self else {
                                                    return
                                                }
                                                //->로그아웃을 기록: 기존에 만들었던 프로그램부분 보안, 페이스북 로그아웃을 완료하면 지금 프로그램에서 완전 로그아웃 처리가 되어서 이중 로그아웃을 처리하지 않아도 되게
                                                FBSDKLoginKit.LoginManager().logOut()
                                                
                                                //구글 로그아웃 처리
                                                GIDSignIn.sharedInstance()?.signOut()
                                                
                                                do {
                                                    try FirebaseAuth.Auth.auth().signOut()
                                                    //->로그아웃에 성공하면 다시 로그인 할 수 있는 첫화면으로 돌아오게 해야한다.
                                                    let vc = LoginViewController()
                                                    let nav = UINavigationController(rootViewController: vc)
                                                    nav.modalPresentationStyle = .fullScreen
                                                    strongSelf.present(nav, animated: true)
                                                    
                                                }catch {
                                                    print("로그아웃에 실패했습니다.")
                                                }
                                                
                                            }))
        //->로그아웃 취소 기능
        actionSheet.addAction(UIAlertAction(title: "취소",
                                            style: .cancel,
                                            handler: nil))
        present(actionSheet, animated: true)
    }
}
