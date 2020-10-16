//
//  FeedViewController.swift
//  fugazigram
//
//  Created by Cyrus Simons on 10/12/20.
//

import UIKit
import Parse
import AlamofireImage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var posts = [PFObject]()
    
    let postRefreshControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        postRefreshControl.addTarget(self, action: #selector(viewDidAppear(_:)), for: .valueChanged)
        tableView.refreshControl = postRefreshControl

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let query = PFQuery(className:"Posts")
        query.includeKeys(["owner", "comments", "comments.owner"])
        query.limit = 20
        
        /*query.findObjectsInBackground { (postsarr, error) in
            if postsarr != nil {
                self.posts = postsarr!
                self.tableView.reloadData()
            } else{ print("error loading posts. None to load.") }
        }*/
        
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let objects = objects {
                // The find succeeded.
                print("Successfully retrieved \(objects.count) scores.")
                // Do something with the found objects
                for object in objects {
                    print(object.objectId as Any)
                }
                self.posts = objects
                self.tableView.reloadData()
                self.postRefreshControl.endRefreshing()
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        return comments.count + 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == 0 {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            
            
            let user = post["owner"] as! PFUser
            cell.unameLabel.text = user.username
            cell.captionLabel.text = post["caption"] as? String
            
            let imageFile = post["image"] as! PFFileObject
            
            let urlstring = imageFile.url!
            let url = URL(string: urlstring)!
            
            cell.photoView.af.setImage(withURL: url)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            
            let comment = comments[indexPath.row - 1]
            
            cell.commentLabel.text = comment["text"] as? String
            
            let user = comment["owner"] as! PFUser
            cell.uNameLabel.text = user.username
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        
        let comment = PFObject(className: "Comments")
        comment["text"] = "random text"
        comment["post"] = post
        comment["owner"] = PFUser.current()!
        
        post.add(comment, forKey: "comments")
        
        post.saveInBackground { (success, error) in
            if success {
                self.dismiss(animated: true, completion: nil)
                print("comment saved")
            }else{ print("error saving comment") }
        }
        
    }
    
    @IBAction func onLogout(_ sender: Any) {
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginView = main.instantiateViewController(identifier: "loginView")
        
        let sceneDelegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        sceneDelegate.window?.rootViewController = loginView
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
