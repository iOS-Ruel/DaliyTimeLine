//
//  AuthService.swift
//  DaliyTimeLine
//
//  Created by Chung Wussup on 1/22/24.
//

import Firebase
import FirebaseAuth
import FirebaseCore

struct AuthCredentials {
    let email: String
    let password: String
    let fullname: String
    let username: String
    let profileImage: UIImage
}

struct AuthService {
    //로그인
    static func logUserIn(withEmail email: String, password: String, compltion:  @escaping (AuthDataResult?, Error?) -> Void) {
        DTL_AUTH.signIn(withEmail: email, password: password, completion: compltion)
    }
    
    
    //사용자 등록
    static func registerUser(withCredential credentials: AuthCredentials, completion: @escaping(Error?) -> Void) {
        //이미지 업로드
        ImageUploader.uploadImage(image: credentials.profileImage) { imageUrl in
            DTL_AUTH.createUser(withEmail: credentials.email, password: credentials.password) { result, error in
                
                
                if let error = error {
                    print("Debug: failed to register user \(error.localizedDescription)")
                    return
                }
                
                guard let uid = result?.user.uid else { return }
                
                let data: [String: Any] = ["email": credentials.email,
                                           "fullname": credentials.fullname,
                                           "profileImageUrl": imageUrl,
                                           "uid": uid,
                                           "username": credentials.username]
                
                COLLECTION_USERS.document(uid).setData(data, completion: completion)
            }
        }
    }
    
    static func resetPassword(withEmail email: String, completion: FirestoreCompletion?) {
        DTL_AUTH.sendPasswordReset(withEmail: email, completion: completion)
    }
    
}
