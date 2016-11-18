import Foundation
import PlaygroundSupport

protocol JSONable {
  init?(json: [String : Any])
  func toJson() -> [String : Any]
}

// TODO: Have PlaceholderPost conform to JSONable
struct PlaceholderPost: CustomStringConvertible {
  /*
   Instructions on completing the PlaceholderPost model
   1. look at the Docs / Postman
   2. create the instance variable
   3. parse out into 100 PlaceholdersPosts
   */
  
  let userID: Int
  let id: Int
  let title: String
  let body: String
  
  /*
   CustomStringConvertible requires a single variable to be defined: description
   
   - Why even conform to CustomStringConvertible, when we can just add a "description" variable?
   -> Because objects that conform to the protocol will let print() statements automatically know
   what should be printed by passing the object in as a sole parameter or in a string interpolation
   
   ---------------------
   example w/o protocol:
   
   let post = PlaceholderPost(userID: 1, id: 1, title: "Title", body: "Body")
   print(post) // prints PlaceholderPost(userId: 1, id: 1, title: "Title", body: "Body")
   
   ---------------------
   example w/ protocol:
   
   let post = PlaceholderPost(userID: 1, id: 1, title: "Title", body: "Body")
   print(post) // prints "TITLE: Title by USER: 1"
   
   ---------------------
   example w/o protocol, but using a variable named 'description':
   
   let post = PlaceholderPost(userID: 1, id: 1, title: "Title", body: "Body")
   print(post) // prints PlaceholderPost(userId: 1, id: 1, title: "Title", body: "Body")
   print(post.description) // prints "TITLE: Title by USER: 1"
   
   - Advanced Note: There are important implications behind the scenes with how Swift handles dynamic dispatch in print(), but that's not entirely relevant or important to know right now. Dynamic dispatch is an abstract concept, and I don't necessarily recommend spending the time to research it at this moment.
   */
  var description: String {
    return "TITLE: \(title) by USER: \(userID)"
  }
  
}

struct PlaceholderComment: JSONable {
  // 1. Instance variables
  let postId: Int
  let id: Int
  let name: String
  let email: String
  let body: String
  
  init?(json: [String : Any]) {
    
    if
      let jId = json["id"] as? Int,
      let jPostId = json["postId"] as? Int,
      let jName = json["name"] as? String,
      let jEmail = json["email"] as? String,
      let jBody = json["body"] as? String {
      self.id = jId
      self.postId = jPostId
      self.name = jName
      self.email = jEmail
      self.body = jBody
      
      // we must return early here! otherwise, execution continues on and hits 
      // "return nil", returning nil when an actual object already has been created
      // see: https://medium.com/@louistur/failable-initializers-with-default-property-values-7b223d2f1b3f#.wzccg3g1t
      return
    }
    
    return nil
  }
  
  /*
    K, I made a mistake in the explanation of member-wise inits in class. Structs do normally come with a "free" initializer in two scenarios:
   1) If you have default values for all of your properties, you're able to instantiate the struct by simply calling StructName().
   2) Structs get a 'member-wise' initializer if they do not define any of their own custom init's
   
   But:
   “Note that if you define a custom initializer for a value type, you will no longer have access to the default initializer (or the memberwise initializer, if it is a structure) for that type. ”
   Excerpt From: Apple Inc. “The Swift Programming Language (Swift 3).” iBooks.
   
   So adding in the init?(json: [String : AnyObject] means we lose our free member-wise initializer. But just because we lose it, doesn't 
   mean we have to add our own! We just have to explicitly write our own if we want/need it.
   
   There is one way around this though: 
   “If you want your custom value type to be initializable with the default initializer and memberwise initializer, and also with your own custom initializers, write your custom initializers in an extension rather than as part of the value type’s original implementation. For more information, see Extensions.”
   
   Excerpt From: Apple Inc. “The Swift Programming Language (Swift 3).” iBooks.
   
   To see what I mean, check out my new model, PlaceholderPhoto, PlaceholderAlbum, below.
   */

  
  func toJson() -> [String : Any] {
    let myDict: [String : Any] = [
      "id" : self.id,
      "postId" : self.postId,
      "name" : self.name,
      "email": self.email,
      "body" : self.body,
    ]
    return myDict
  }
}

// PlaceholderPhoto: Free member-wise init
struct PlaceholderPhoto {
  let albumId: Int
  let id: Int
  let title: String
  let url: String
  let thumbnailUrl: String
  // this struct gets a free, member-wise initializer: PlaceholderPhoto(albumId: Int, id: Int, title: String, url: String, thumbnailUrl: String)
}
PlaceholderPhoto(albumId: 1, id: 1, title: "", url: "", thumbnailUrl: "")

// PlaceholderAlbum: Free default init
struct PlaceholderAlbum {
  let userId: Int = -1
  let id: Int = -1
  let title: String = "Default Title"
  
  // this struct gets a free default init: PlaceholderAlbum()
}
PlaceholderAlbum()

// PlaceholderTodo: uses extensions to keep it's free member-wise init, while giving it a custom one as well.
struct PlaceholderTodo {
  let userId: Int
  let id: Int
  let title: String
  let completed: Bool
  
  // Free member-wise init: PlaceholderTodo(userId: Int, id: Int, title: String, completed: Bool)
}

extension PlaceholderTodo: JSONable {

  init?(json: [String : Any]) {
    
    guard let userId = json["userId"] as? Int,
    let id = json["id"] as? Int,
    let title = json["title"] as? String,
    let completed = json["completed"] as? Bool else {
      return nil
    }
    
    self.userId = userId
    self.id = id
    self.title = title
    self.completed = completed
  }
  
  func toJson() -> [String : Any] {
    return [
      "userId" : self.userId,
      "id" : self.id,
      "title" : self.title,
      "completed" : self.completed
    ]
  }
  
  // Still has member-wise + new init from JSONable protocol
}

PlaceholderTodo(json: [:])
PlaceholderPost(userID: 1, id: 1, title: "", body: "")

// MARK: - Morning Example (Reviewing what we know w/ URLSession)
func baselineURLSession() {
  
  // 1. Make a session w/ default configuration
  let session = URLSession(configuration: URLSessionConfiguration.default)
  
  // 2. Create our URL
  // -> Remember to Option-Click variables/parameters to understand their types
  // -> Doing so will let you know why we're doing a force unwrap here
  let url = URL(string: "https://randomuser.me/api")!
  
  // 3. Create our data task
  session.dataTask(with: url, completionHandler: { (data: Data?, _, _) in
    
    // 5. Check for data
    // -> And realistically, you would check for errors as well. But in this contrived review example we're not concerned with it
    if data != nil {
      print("YAYYYY DATA: \(data!)")
      
      do {
        
        // 6. serialize and make objects
        let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
        
        // -> We aren't concerned with parsing this, just making sure it works
        if let validJson = json {
          print(validJson)
        }
      }
      catch {
        print("Problem casting json: \(error)")
      }
      
    }
    
    // 4. Start our data task
  }).resume()
}

// MARK: - Morning Example (Reviewing what we know w/ URLSession and applying it to URLRequest)
func newRequest() {
  
  // 1. Create our url, force unwrapping it
  let url = URL(string: "https://randomuser.me/api")!
  
  // 2. Create our request with the url and customize our requests
  // -> We specify the httpMethod as "GET" for illustrative purpose (it's already the default)
  // -> We specify a header key/value for illustrative purpose (for this API, we learned headers will be ignored if not expected or incorrect)
  var request: URLRequest = URLRequest(url: url)
  request.httpMethod = "GET"
  request.addValue("application/json", forHTTPHeaderField: "Content-Type")
  
  // 3. Create our session and data task
  // -> This time we're using dataTask(with: URLRequest), instead of dataTask(with: URL)
  let session = URLSession(configuration: URLSessionConfiguration.default)
  session.dataTask(with: request) { (data: Data?, _, _) in
    
    // 5. Check for data
    // -> Again, you should normally check for errors -- right now we don't care about it
    if data != nil {
      do {
        
        // 6. serialize and make objects
        let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
        
        // -> Again, We aren't concerned with parsing this, just making sure it works
        if let validJson = json {
          print(validJson)
        }
        
      }
      catch {
        print("Error parsing: \(error)")
      }
      
    }
    
    // 4. Start the data task
    }.resume()
  
}

// MARK: - Working with URLRequest and JsonPlaceholder API
func getPlaceholderRequest() {
  
  // 1. Create the URL
  let eddyTheDucksURL = URL(string: "https://jsonplaceholder.typicode.com/posts")!
  
  // 2. Create the request and customize
  var weirdRequest = URLRequest(url: eddyTheDucksURL)
  weirdRequest.httpMethod = "GET"
  
  // 3. Create session and datatask
  let session = URLSession(configuration: URLSessionConfiguration.default)
  session.dataTask(with: weirdRequest) {( weirdData: Data?, _, weirdError: Error?) in
    
    // In the reading, they gave the URL example using Foundation types: NSURLRequest/NSMutableURLRequest
    // - Objc -
    // NSMutableURLRequest
    // NSURLRequest
    
    // - Swift -
    // URLRequest
    // let weirdRequest = URLRequest(url: eddyTheDucksURL) <--- Equiv to NSURLRequest
    // var weirdRequest = URLRequest(url: eddyTheDucksURL) <--- Equiv to NSMutableURLRequest
    
    // 5. Check for errors and data
    if weirdError != nil {
      print(weirdError!)
    }
    
    if weirdData != nil {
      do {
        
        // 6. serialize and make object
        let json = try JSONSerialization.jsonObject(with: weirdData!, options: []) as? [[String : Any]]
        
        if let validJson = json {
          print(validJson)
          
          // 7. MAKE THE WEIRD MODELS x 100
          var weirdResultArray: [PlaceholderPost] = []
          for weirdJson in validJson {
            
            // -> I haven't seen this style of guard syntax anywhere; it's just one I came up with. I like it, and happen to think it is more reable in this form. There will be developers that disagree with me, and you may be one. Ultimately, use what you think is best, but be aware that you will likely receive push back depending on who works on your code with you. What's important to note is that as long as you can make a good argument for doing something in a specific syntactic way, you may be able to persuade your team to follow your new style.
            
            // Warning: "I think it reads better" is a weak argument, as it's mostly (my) opinion.
            guard
              let userId = weirdJson["userId"] as? Int,
              let id = weirdJson["id"] as? Int,
              let title = weirdJson["title"] as? String,
              let body = weirdJson["body"] as? String
            else { return }
            
            let weirdResult = PlaceholderPost(userID: userId, id: id, title: title, body: body)
            weirdResultArray.append(weirdResult)
            
            //            print(weirdResult)
          }
          
          //          print(weirdResultArray)
        }
      }
      catch {
        print("Problem casting json: \(error)")
      }
    }
    
    // 4. Begin the task
    }.resume()
}

// MARK: - Working with URLRequest with POST
func postPlaceholderRequest() {
  
  // 1. Create URL
  let freddyMercurysURL = URL(string: "https://jsonplaceholder.typicode.com/posts")!
  
  // 2. Create and customize the request
  // -> Here, we change the httpMethod to POST
  // -> We additionally need to set some Data for its httpBody as this API expects that for POST requests
  var bohemianRequest = URLRequest(url: freddyMercurysURL)
  bohemianRequest.httpMethod = "POST"
  
  let bohemianBicycleBody: [String : Any] = [
    "userId" : 5,
    "title" : "Ride My Bicycle",
    "body" : "I like to ride my bicycle, I like to ride my bike."
  ]
  
  // 3. We need to convert our Dictionary into Data using JSONSerialization
  // -> Essentially, this is reversing what we've been using JSONSerialization for up to this point: instead of taking Data from a request to convert it to a dictionary, we're taking a dictionary and converting it to Data
  do {
    let bohemianData = try JSONSerialization.data(withJSONObject: bohemianBicycleBody, options: [])
    
    // 4. Set the httpBody to the value of the serialized dictionary
    bohemianRequest.httpBody = bohemianData
  }
  catch {
    print("Error creating the bohemian data: \(error)")
  }
  
  // 5. Create the session and data task
  let session = URLSession(configuration: URLSessionConfiguration.default)
  session.dataTask(with: bohemianRequest) { (data: Data?, _, bohemianError: Error?) in
    
    // 7. Check for errors and Data
    if bohemianError != nil {
      print(bohemianError!)
    }
    
    if data != nil {
      print(data!)
      
      do {
        
        // 8. serialize and make objects
        let bohemianJson = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
        
        if let validJson = bohemianJson {
          print(validJson)
          /*
           What do we do with this data now, assuming it's valid? Well, whatever you need to do with it. In this contrived example, we don't really need to do anything. Maybe we could print out the PlaceholderPost object returned if we wanted.
           
           If this was an actual app, we might want to verify that the PlaceholderPost we sent in, is the same one we're getting back. And in performing that check, we can determine if the request was successful. From there we could decided how to proceed (alert the user, pop the view controller we're on, etc..)
           
           
           pseudo code:
           if createPlaceholder(validJson) {
           alert("All went well!")
           }
           else {
           alert("Error with posting!")
           }
           
           */
          
        }
        
      }
      catch {
        print("Error encountered parsing: \(error)")
      }
    }
    
    // 6. Launch the data task
    }.resume()
  
  
}

// TODO: Exercises
func putPlaceholderRequest() { /* later code! */
  let url = URL(string: "http://jsonplaceholder.typicode.com/posts/1")!
  var request = URLRequest(url: url)
  request.httpMethod = "PUT"
  request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
  
  let body: [String : Any] = [
    "id" : 1,
    "userId" : 1,
    "title" : "New Title",
    "body" : "New Body"
  ]
  
  do {
    let data = try JSONSerialization.data(withJSONObject: body, options: [])
    
    request.httpBody = data
  }
  catch {
    print("Error serializing to Data: \(error)")
  }
  
  let session = URLSession(configuration: .default)
  session.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) in
    
    if error != nil {
      print(error.unsafelyUnwrapped)
    }
    
    if data != nil {
      print(data!)
      
      do {
        let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
        
        if let validJson = json {
          print(validJson)
        }
        
      }
      catch {
        
      }
    }
    
  }).resume()
}

func deletePlaceholderRequest() {
  let url = URL(string: "http://jsonplaceholder.typicode.com/posts/1")!
  var request = URLRequest(url: url)
  request.httpMethod = "DELETE"
  request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
  
  let session = URLSession(configuration: .default)
  session.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) in
  
    if error != nil {
      print(error.unsafelyUnwrapped)
    }
    
    if data != nil {
      print(data!)

      do {
        let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
        
        if let validJson = json {
          print(validJson)
        }
        
      }
      catch {
        print("Error")
      }

    }
  
  }).resume()
}

// MARK: - Comments Functions
func postComment() {
  let url = URL(string: "http://jsonplaceholder.typicode.com/comments")!
  
  var request = URLRequest(url: url)
  request.httpMethod = "POST"
  
  // this line below was the fix to our malformed return json
  request.addValue("application/json", forHTTPHeaderField: "Content-Type")
  
  let dict: [String : Any] = [
    "postId"  : 1,
    "id" : 1,
    "name" : "Tom",
    "email" : "tom@here.com",
    "body" : "Tom has a lovely body"
  ]
  
  do {
    let commentData = try JSONSerialization.data(withJSONObject: dict, options: [])
    
    request.httpBody = commentData
  }
  catch {
    print("Error: \(error)")
  }
  
  let session = URLSession(configuration: .default)
  session.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) in
    
    if error != nil {
      print(error.unsafelyUnwrapped) // unsafelyUnwrapped means the same as ! 
    }
    
    if response != nil {
      print(response.unsafelyUnwrapped)
      if let httpResponse = response as? HTTPURLResponse {
        print(httpResponse.statusCode) // we were looking for status codes in the 200's
      }
    }
    
    if data != nil {
      print(data!)
      
      do {
        let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
        dump(json)
        
        if let validJson = json{
          dump(validJson)
          
          let reconstructedObject = PlaceholderComment(json: validJson)
          dump(reconstructedObject)
        }
      }
      catch {
        print("Error encountered serializing: \(error)")
      }
    }
  
  }).resume()
}

func putComment() {
  
}

func deleteComment() {
  
}

/*
  Count Quackula, what components do I need for each of these requests? 
 
  1. Id of the comment/user/etc
  2. http verb (always)
  3. possibly dict for the body (patch/put/post)
  4. possibly headers (put/post)
 
  Ah yes. That is how I should plan out this function.
 
  Q1. What other parameter could be added to make this work with other endpoints?
  Q2. What would need to be changed to support different endpoints + GET requests?
 
  A1 & A2: adding a URL parameter for endpoint (implemented below)
 */
func makeRequest(endpoint: URL, method: String = "GET", body: [String : Any]?, headers: [String : String]?) {
  
  // Q1. How would you handle header info?
  var request: URLRequest = URLRequest(url: endpoint)
  if headers != nil {
    for (key, value) in headers! {
      request.setValue(value, forHTTPHeaderField: key)
    }
  }
  
}

//baselineURLSession()
//newRequest()
//getPlaceholderRequest()
//postPlaceholderRequest()
//putPlaceholderRequest()
//deletePlaceholderRequest()
//postComment()

/*
 Why do we need this needsIndefiniteExecution propery set to true?
 
 Well, a playground executes its code, line by line, until it reaches the end of the file. At that point, execution terminates and starts over automatically (if you have auto-run enabled. otherwise, execution just ends).
 
 Why does this matter?
 
 Execution for a playground ends the moment the last line is encountered and run. Any asynchronous tasks that are launched, but don't complete in the time Swift needs to run all of the lines of code, the playground will terminate early. So our asynchronous network call gets cancelled long before it finishes.
 By saying that a playground needs indefinite execution time, it signals that the playground needs to keep running code after the last line is reached. In that way, we ensure that an async network call has enough time to be completed
 */
PlaygroundPage.current.needsIndefiniteExecution = true
