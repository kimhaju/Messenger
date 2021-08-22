//
//  DatabaseManager.swift
//  Messenger
//
//  Created by haju Kim on 2021/08/21.
//

import Foundation
import FirebaseDatabase

//->데이터 베이스 연결
final class DatabaseManager {
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
}
//->확장한 데이터 베이스 매니저에 유저를 생성하는 메서드를 추가 해준다.
extension DatabaseManager {
    //->삽입 쿼리 처리
    public func userExists(with email: String,
                                completion: @escaping (Bool) -> Void) {
        //->이 작업은 왜? 데이터 베이스 형태에 이메일 형식 그대로 저장 불가. 그래서 불가능한 문자들은 치환해서 저장해주는 작업이 필수
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    ///유저 추가 메서드+데이터 베이스(///는 자동완성으로 만들어줌)
    public func insertUser(with user: ChatAppUser){
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ])
    }
}
//->저장할 유저정보를 여기에 설정
struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress : String
    
    //->여기에 세이프 이메일을 만든 이유?: 재활용 가능!
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    //->비밀번호 저장은 왜 안해?
    //->암호화 작업(솔트) 그걸 안해서 지금 공개된 데이터에 베이스에 추가하는건 그닥 좋은 생각X
//    let password : String
}
