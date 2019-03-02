//
//  Api.swift
//  StudyAtlas
//
//  Created by Jacob Morris on 11/18/18.
//  Copyright © 2018 Jaime Park. All rights reserved.
//

import Foundation
import FirebaseFirestore
struct Api {
    static var db = Firestore.firestore()
    
    struct postInfo {
        var collection : String
        var document : String?
        var data: [String : Any]
    }
    
    typealias ApiCompletion = ((_ response: [String: Any]?, _ error: String?) -> Void)
    typealias ApiCompletionList = ((_ response: [[String: Any]]?, _ error: String?) -> Void)
    
    /**
        retrieves a specific document based on a provided
        document name and collection name
    */
    static func getDocument(_ collection : String, _ document : String,  completion: @escaping ApiCompletion) {
        let docRef = db.collection(collection).document(document)
        docRef.getDocument { (document, error) in
            //get a specific document from a collection
            if let document = document, document.exists {
                let dataDescription = document.data() ?? nil
                    completion(dataDescription, nil)
            } else {
                completion(nil, "Document does not exist")
            }
        }
    }
    /**
     returns all documents from a collection
    */
    static func getCollection(_ collection : String, completion: @escaping ApiCompletionList) {
        let docRef = db.collection(collection)
        docRef.getDocuments { (querySnapshot, error) in
            if let documents = querySnapshot?.documents {
                var allDocs : [[String : Any]] = []
                for document in documents { //get all documents from collection
                    allDocs.append(document.data())
                }
                //return list of dictionaries for all documents
                completion(allDocs, nil)
            } else {
                completion(nil, "Collection does not exist")
            }
        }
    }
    
    /**
        Update the count of users for the provided place
        return current count if needed
    */
    static func changePlaceCount(_ site: String, _ add : Bool, completion: @escaping ((_ count : Int ) -> Void)) {
        let collectionRef = db.collection("places")
        //get all updates for location and sort by most recent
        let query = collectionRef.whereField("name", isEqualTo: site)
        
        query.getDocuments { (querySnapshot, error) in
            if let documents = querySnapshot?.documents {
                if documents.count == 0 {
                    return
                }
                let document = documents[0]
                let docID = document.documentID
                let docRef = collectionRef.document(docID)
                if let count = document.data()["count"] as? Int {
                    if add { //increment user count
                        docRef.setData(["count" : count + 1], merge: true)
                    } else if count != 0 && !add { //decrement
                        docRef.setData(["count" : count - 1], merge: true)
                    }
                    
                    completion(count) //return total count
                } else { //no count added yet
                    docRef.setData(["count" : 0], merge: true)
                }
                
            } else { //error occurred, add to log
                print("error type:")
                dump(error!)

            }
        }
        
        completion(0)
    }
    
    /**
     Get all updates for a given study location
    */
    static func getUpdates(_ location : String, completion: @escaping ApiCompletionList) {
        let docRef = db.collection("updates")
        //get all updates for location and sort by most recent
        let query = docRef.whereField("site", isEqualTo: location).order(by: "time", descending: true)
        
        //get the updates from server
        query.getDocuments { (querySnapshot, error) in
            if let documents = querySnapshot?.documents {
                var allDocs : [[String : Any]] = []
                dump(documents)
                dump(allDocs)
                for document in documents {
                    allDocs.append(document.data().mapValues { String.init(describing: $0)
                        
                    })
                } //add all documents to a dictionary of dictionaries
                //key is the name of the document (good for iterating through location
                completion(allDocs, nil)
            } else {
                print("error type:")
                dump(error!)
                completion(nil, "Collection does not exist")
            }
        }
    }
    
    /**
     submit a post to the database
    */
    static func post(_ options : postInfo) {
        let docRef = db.collection(options.collection)
        if let document = options.document { //specify a name for document
            docRef.document(document).setData(options.data)
        } else { //use an autogenerated name for document
            docRef.document().setData(options.data)
        }
    }
 
    /**
     Submits an update for a given update request
    */
    static func userPost(_ formData : [String : Any]) {
        var data = formData
        data["time"] = FieldValue.serverTimestamp() //timestamp function
        let postData = postInfo(collection: "updates", document: nil, data: data)
        post(postData)
    }
 
}
