//
//  PostService.swift
//  Boss5207418
//
//  Created by Rachelle Ford on 6/16/23.
//

import Foundation
import FirebaseAuth
import Firebase
import FirebaseFirestore
import FirebaseStorage


class PostService: ObservableObject {
    
    static var Posts = AuthService.storeRoot.collection("posts")
    
    static var AllPosts = AuthService.storeRoot.collection("allPosts")
    static var Timeline = AuthService.storeRoot.collection("timeline")
    
    static func PostsUserId(userId: String) -> DocumentReference {
        return Posts.document(userId)
    }
    static func timelineUserId(userId: String) -> DocumentReference {
        return Timeline.document(userId)
    }
    
    static func uploadPost(caption: String, imageData: Data, onSuccess: @escaping()-> Void, onError: @escaping (_ errorMessage: String) -> Void) {
        
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
        let postId = PostService.PostsUserId(userId: userId).collection("posts").document().documentID
        
        let storagePostRef = StorageService.storagePostId(postId: postId)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        StorageService.savePostPhoto(userId: userId, caption: caption, postId: postId, imageData: imageData, metadata: metadata, storagePostRef: storagePostRef, onSuccess: onSuccess, onError: onError)
        
    }
    
    
    static func loadUserPosts(userId: String, onSuccess: @escaping(_ posts: [PostModel]) -> Void) {
        PostService.PostsUserId(userId: userId).collection("posts").getDocuments { (snapshot, error) in
            guard let snap = snapshot else {
                print("Error")
                return
            }
            
            var posts = [PostModel]()
            
            for doc in snap.documents {
                let dict = doc.data()
                
                guard let userDict = dict["user"] as? [String: Any] else {
                    print("Error: User data not found")
                    continue
                }
                
                guard let uid = userDict["uid"] as? String,
                      let email = userDict["email"] as? String,
                      let profileImageUrl = userDict["profileImageUrl"] as? String,
                      let username = userDict["username"] as? String,
                      let searchName = userDict["searchName"] as? [String],
                      let bio = userDict["bio"] as? String,
                      let website = userDict["website"] as? String,
                      let isVerified = userDict["isVerified"] as? Bool
                else {
                    print("Error: Invalid user data")
                    continue
                }
                
                let user = User(
                    id: "", uid: uid,
                    email: email,
                    profileImageUrl: profileImageUrl,
                    username: username,
                    searchName: searchName,
                    bio: bio,
                    website: website,
                    isVerified: isVerified
                )
                
                let post = PostModel(
                    id: doc.documentID,
                    title: dict["title"] as? String ?? "",
                    time: (dict["time"] as? Timestamp)?.dateValue() ?? Date(),
                    user: user,
                    caption: dict["caption"] as? String ?? "",
                    likes: dict["likes"] as? [String: Bool] ?? [:],
                    geoLocation: dict["geoLocation"] as? String ?? "",
                    ownerId: dict["ownerId"] as? String ?? "",
                    postId: dict["postId"] as? String ?? "",
                    username: dict["username"] as? String ?? "",
                    profile: dict["profile"] as? String ?? "",
                    mediaUrl: dict["mediaUrl"] as? String ?? "",
                    date: dict["date"] as? Double ?? 0.0,
                    likeCount: dict["likeCount"] as? Int ?? 0,
                    isVerified: false
                )
                
                posts.append(post)
            }
            
            onSuccess(posts)
        }
    }
}
