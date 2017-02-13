//
//  NetworkManager.swift
//  RedRoster
//
//  Created by Daniel Li on 3/25/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import GoogleSignIn
import RealmSwift

enum Router: URLConvertible {
    /// Returns a URL that conforms to RFC 2396 or throws an `Error`.
    ///
    /// - throws: An `Error` if the type cannot be converted to a `URL`.
    ///
    /// - returns: A URL or throws an `Error`.
    public func asURL() throws -> URL {
        let path: String = {
            switch self {
            case .signIn:
                return "/sign_in"
            case .terms:
                return "/courses"
            case .subjects(let term):
                return "/courses/\(term)"
            case .courses(let term, let subject):
                return "/courses/\(term)/\(subject)"
            case .showCourse(let term, let subject, let course):
                return "/courses/\(term)/\(subject)/\(course)"
            case .searchCourses(let term, let query):
                return "/courses/search/\(term)/\(query)"
            case .postReview:
                return "/course_reviews/create"
            case .fetchReviews(let id):
                return "/course_reviews/\(id)"
            case .postSchedule:
                return "/schedules/create"
            case .showSchedule(let id):
                return "/schedules/show/\(id)"
            case .fetchSchedules(let id):
                return "/schedules/index/\(id)"
            case .makeSchedulePublic(let id):
                return "/schedules/make_active/\(id)"
            case .renameSchedule(let id):
                return "/schedules/rename/\(id)"
            case .deleteSchedule(let id):
                return "/schedules/delete/\(id)"
            case .postElement:
                return "/schedule_elements/create"
            case .deleteElement:
                return "/schedule_elements/delete"
            case .searchUsers(let query):
                return "/users/search/\(query)"
            case .requestFollow:
                return "/following_requests/create"
            case .reactToFollowRequest(let accept):
                return "/following_requests/react_to_request/\(accept)"
            case .fetchFollowers:
                return "/followings/fetch_followers"
            case .fetchFollowing:
                return "/followings/fetch_followees"
            }
        }()
        return URL(string: Router.BackendHostURL + path)!
    }

    
    case signIn
    
    case terms
    case subjects(term: String)
    case courses(term: String, subject: String)
    case showCourse(term: String, subject: String, course: Int)
    case searchCourses(term: String, query: String)
    
    case postReview
    case fetchReviews(id: Int)
    
    case postSchedule
    case showSchedule(id: Int)
    case fetchSchedules(id: Int)
    case makeSchedulePublic(id: Int)
    case renameSchedule(id: Int)
    case deleteSchedule(id: Int)
    
    case postElement
    case deleteElement
    
    case searchUsers(query: String)
    
    case requestFollow
    case reactToFollowRequest(accept: Bool)
    
    case fetchFollowers
    case fetchFollowing
    
    static let BackendHostURL =     "https://redroster.me/api/v1"
    static let CornellClassesURL =  "https://classes.cornell.edu/api/2.0"
    
}

let RailsDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSS'Z'"
    return formatter
}()

let RedRosterErrorDomain = "RedRosterDomain"

let RealmStringSeparator = "||"

var UserSignedIn: Bool {
    return GIDSignIn.sharedInstance().hasAuthInKeychain()
}

extension String {
    var unseparatedValues: [String] {
        get {
            return isEmpty ? [] : components(separatedBy: RealmStringSeparator)
        }
        set {
            self = newValue.joined(separator: RealmStringSeparator)
        }
    }
}

/** NetworkManager manages all API requests and responses and other general networking. */
class NetworkManager {
    
    // Prevent initialization
    init() {    }
    
    static let queue = DispatchQueue(label: "com.redroster.network-queue", attributes: DispatchQueue.Attributes.concurrent)
    
    // MARK: - Parameters
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()
    
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "hh:mma"
        return formatter
    }()
    
    /// Create parameters with authentication
    static func parametersWithAuth(_ parameters: [String : Any] = [:]) -> [String : Any] {
        var dict: [String : Any] = [
            "id_token" : GIDSignIn.sharedInstance().currentUser.authentication.idToken as Any
        ]
        
        for (key, value) in parameters {
            dict[key] = value
        }
        
        return dict
    }
    
    /***************** REQUESTS *****************/
    
    fileprivate static let Verbose = true
    
    // MARK: - Base Request
    
    static func makeRequest(_ method: Alamofire.HTTPMethod, params: [String: Any] = [:], auth: Bool, router: Router, searchRequest: Bool = false, completion: @escaping (_ data: JSON?, _ error: NSError?) -> Void) {
        
        searchRequests.forEach { $0.cancel() }
        searchRequests.removeAll()
        
        var parameters = auth ? parametersWithAuth(params) : params
        parameters["api_key"] = RedRosterAPIKey
        
        let request: Request = Alamofire
            .request(router, method: method, parameters: parameters)
            .responseJSON(queue: queue, completionHandler: { response in
                if Verbose {
                    print()
                    print("**************************************** NEW REQUEST *************************************")
                    print()
                    try? print("URL: " + router.asURL().absoluteString)
                    print()
                    print("PARAMETERS: \(parameters)")
                }
                
                if let error = response.result.error {
                    if Verbose {
                        print()
                        print("ERROR: (code: \(error.localizedDescription)")
                        print()
                    }
                    
                    // cast as NSError
                    completion(nil, nil)
                    return
                }
                
                let json = JSON(data: response.data!)
                if Verbose {
                    print()
                    print("RESPONSE:")
                    print()
                    print(json)
                }
                
                if json["success"].bool == true {
                    completion(json["data"], nil)
                } else {
                    let error = json["data"]["errors"].array?.first?.string
                }
            })
        if searchRequest {
            searchRequests.append(request)
        }
    }
    
    // MARK: - Sign In
    
    /// Validate Sign In with backend server. Completion handler contains newUser Bool.
    static func validateSignIn(_ completion: @escaping (_ newUser: Bool?, _ error: NSError?) -> Void) {
        makeRequest(.post, auth: true, router: .signIn) { data, error in
            DispatchQueue.main.async {
                let defaults = UserDefaults.standard
                defaults.set(data?["user"]["id"].int ?? -1, forKey: "currentUserId")
                completion(data?["new_user"].bool, error)
            }
        }
    }
    
    // MARK: - Course Roster
    
    /// Fetch Terms for the given year from Cornell
    static func fetchTerms(_ completion: @escaping (_ error: NSError?) -> Void) {
        makeRequest(.get, auth: false, router: .terms) { data, error in
            let realm = try! Realm()
            try! realm.write {
                data?["terms"].array?.forEach { term in
                    realm.add(Term.create(term.stringValue))
                }
            }
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    /// Fetch Subjects for a given Term
    static func fetchSubjects(termWithSlug slug: String, completion: @escaping (_ error: NSError?) -> Void) {
        makeRequest(.get, auth: false, router: .subjects(term: slug)) { data, error in
            if let subjectsJSON = data?["subjects"].array {
                let realm = try! Realm()
                guard let term = realm.object(ofType: Term.self, forPrimaryKey: slug) else { return }
                try! realm.write {
                    term.subjects.removeAll()
                    term.subjects.append(objectsIn: subjectsJSON.map {
                        Subject.create($0, termSlug: slug)
                    })
                }
            }
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    /// Fetch Courses in a given Subject
    static func fetchCourses(subjectWithId id: String, andAbbreviation abbreviation: String, termSlug slug: String, completion: @escaping (_ error: NSError?) -> Void) {
        makeRequest(.get, auth: false, router: .courses(term: slug, subject: abbreviation)) { data, error in
            if let coursesJSON = data?["courses"].array {
                let realm = try! Realm()
                guard let subject = realm.object(ofType: Subject.self, forPrimaryKey: id) else { return }
                try! realm.write {
                    subject.courses.removeAll()
                    subject.courses.append(objectsIn: coursesJSON.map {
                        Course.create($0, readOnly: false).0
                    })
                }
            }
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    /// Fetch Course Info
    static func fetchCourse(inTermWithSlug slug: String, forSubject subject: String, withNumber number: Int, completion: @escaping (_ users: [User]?, _ error: NSError?) -> Void) {
        makeRequest(.get, auth: false, router: .showCourse(term: slug, subject: subject, course: number)) { data, error in
            var users: [User]?
            if let courseJSON = data?["course"] {
                do {
                    let realm = try Realm()
                    try realm.write {
                        let course = Course.create(courseJSON, readOnly: false)
                        realm.add(course.0, update: true)
                        users = course.1
                    }
                } catch let error {
                    print("Error occurred fetching course info to realm: \(error)")
                }
            }
            DispatchQueue.main.async {
                completion(users, error)
            }
        }
    }
    
    // MARK: - Reviews
    
    /// Fetch Review statistics and Reviews for a given Course
    static func fetchReviews(_ course: Course, completion: @escaping (_ statistics: ReviewStatistics?, _ reviews: [Review]?, _ error: NSError?) -> Void) {
        makeRequest(.get, auth: true, router: .fetchReviews(id: course.courseId)) { data, error in
            var statistics: ReviewStatistics?
            var reviews: [Review]?
            if let statsJSON = data?["review_statistics"] {
                statistics = ReviewStatistics.create(statsJSON)
                reviews = data?["reviews"].array?.map { Review(json: $0) } ?? []
            }
            DispatchQueue.main.async {
                completion(statistics, reviews, error)
            }
        }
    }
    
    /// Create a Review
    static func postReview(_ course: Course, ratings: ReviewStatistics, feedback: String, term: Term, completion: @escaping (_ statistics: ReviewStatistics?, _ reviews: [Review]?, _ error: NSError?) -> Void) {
        let parameters: [String : Any] = [
            "course_review" : [
                "term" : term.slug,
                "crse_id" : course.courseId,
                "lecture_score" : ratings.lecture,
                "office_hours_score" : ratings.officeHours,
                "difficulty_score" : ratings.difficulty,
                "material_score" : ratings.material,
                "feedback" : feedback
            ]
        ]
        makeRequest(.post, params: parameters, auth: true, router: .postReview) { data, error in
            var statistics: ReviewStatistics?
            var reviews: [Review]?
            if let statsJSON = data?["review_statistics"] {
                statistics = ReviewStatistics.create(statsJSON)
                reviews = data?["reviews"].array?.map { Review(json: $0) } ?? []
            }
            DispatchQueue.main.async {
                completion(statistics, reviews, error)
            }
        }
    }
    
    // MARK: - Schedule
    
    /// Post a Schedule
    static func postSchedule(_ name: String, termWithSlug slug: String, active: Bool, completion: @escaping (_ error: NSError?) -> Void) {
        let parameters: [String : Any] = [
            "schedule" : [
                "name" : name,
                "term" : slug,
                "is_active" : active
            ]
        ]
        makeRequest(.post, params: parameters, auth: true, router: .postSchedule) { data, error in
            if let data = data {
                do {
                    let realm = try Realm()
                    try realm.write {
                        let schedule = Schedule.create(data, readOnly: false)
                        realm.add(schedule)
                        if schedule.active {
                            for schedule in realm.objects(Schedule.self).filter("term.slug == %@ AND id != %@", slug, schedule.id) {
                                schedule.active = false
                            }
                        }
                    }
                } catch let error {
                    print("Error occurred saving posted schedule to realm: \(error)")
                }
            }
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    /// Fetch in-depth information about a Schedule
    static func fetchScheduleInfo(scheduleWithId id: Int, completion: @escaping (_ error: NSError?) -> Void) {
        makeRequest(.get, auth: true, router: .showSchedule(id: id)) { data, error in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    /// Fetch Schedules
    static func fetchSchedules(forUserWithid id: Int, readOnly: Bool, completion: @escaping (_ schedules: [Schedule]?, _ error: NSError?) -> Void) {
        makeRequest(.get, auth: true, router: .fetchSchedules(id: id)) { data, error in
            var schedules: [Schedule]?
            if let array = data?["schedules"].array {
                if readOnly {
                    schedules = array.map { Schedule.create($0, readOnly: readOnly) }
                } else {
                    do {
                        let realm = try Realm()
                        try realm.write {
                            realm.delete(realm.objects(Schedule.self))
                            array.forEach { schedule in
                                realm.add(Schedule.create(schedule, readOnly: readOnly))
                            }
                        }
                    } catch let error {
                        print("Error occurred saving schedules to realm: \(error)")
                    }
                }
            }
            DispatchQueue.main.async {
                completion(schedules, error)
            }
        }
    }
    
    /// Makes a Schedule public
    static func makeSchedulePublic(withId id: Int, completion: @escaping (_ error: NSError?) -> Void) {
        makeRequest(.post, auth: true, router: .makeSchedulePublic(id: id)) { data, error in
            if error == nil {
                do {
                    let realm = try Realm()
                    if let schedule = realm.object(ofType: Schedule.self, forPrimaryKey: id),
                        let slug = schedule.term?.slug {
                        try realm.write {
                            for schedule in realm.objects(Schedule.self).filter("term.slug == %@", slug) {
                                schedule.active = false
                            }
                            schedule.active = true
                        }
                    }
                } catch let error {
                    print("Error occurred making schedule public: \(error)")
                }
            }
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    static func renameSchedule(withId id: Int, toName name: String, completion: @escaping (_ error: NSError?) -> Void) {
        let parameters: [String : Any] = [
            "schedule" : [
                "name" : name
            ]
        ]
        makeRequest(.post, params: parameters, auth: true, router: .renameSchedule(id: id)) { data, error in
            if error == nil {
                let realm = try! Realm()
                let schedule = realm.object(ofType: Schedule.self, forPrimaryKey: id)
                try! realm.write {
                    schedule?.name = name
                }
            }
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    /// Deletes a Schedule
    static func deleteSchedule(withId id: Int, completion: @escaping (_ error: NSError?) -> Void) {
        makeRequest(.delete, auth: true, router: .deleteSchedule(id: id)) { data, error in
            if error == nil {
                do {
                    let realm = try Realm()
                    if let schedule = realm.object(ofType: Schedule.self, forPrimaryKey: id) {
                        try realm.write {
                            realm.delete(schedule)
                        }
                    }
                } catch let error {
                    print("Error occurred deleting schedule from realm: \(error)")
                }
            }
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    /// Posts a Course to a Schedule and updates that Schedule
    static func postCourse(_ schedule: Schedule, course: Course, classNumbers: [Int], completion: @escaping (_ error: NSError?) -> Void) {
        let parameters: [String:Any] = [
            "schedule_element" : [
                "term" : schedule.term?.slug ?? "",
                "crse_id" : course.courseId,
                "subject" : course.activeSubjectAbbreviation,
                "number" : course.activeCourseNumber,
                "schedule_id" : schedule.id,
                "section_num" : classNumbers
            ]
        ]
        makeRequest(.post, params: parameters, auth: true, router: .postElement) { data, error in
            if let data = data {
                do {
                    let realm = try Realm()
                    try realm.write {
                        let schedule = Schedule.create(data, readOnly: false)
                        realm.add(schedule, update: true)
                    }
                } catch let error {
                    print("Error occurred posting course to realm: \(error)")
                }
            }
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    /// Delete an Elements of a Schedule
    static func deleteElements(_ schedule: Schedule, elementsWithIds: [Int], completion: @escaping (_ error: NSError?) -> Void) {
        let parameters: [String:Any] = [
            "schedule_element" : [
                "id" : elementsWithIds,
                "schedule_id" : schedule.id
            ]
        ]
        makeRequest(.delete, params: parameters, auth: true, router: .deleteElement) { data, error in
            if let data = data {
                do {
                    let realm = try Realm()
                    try realm.write {
                        realm.add(Schedule.create(data, readOnly: false), update: true)
                    }
                } catch let error {
                    print("Error occurred deleting elements from realm: \(error)")
                }
            }
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    // MARK: - People
    
    /// Requests to Follow another user
//    static func requestFollow(userId: Int, completion: (error: NSError?) -> Void) {
//        let parameters: [String : Any] = [
//            APIKey.FollowingRequest : [
//                APIKey.UserId : userId
//            ]
//        ]
//        makeRequest(.post, params: parameters, auth: true, router: .RequestFollow) { data, error in
//            completion(error: error)
//        }
//    }
//    
//    static func reactToFollowRequest(withId id: Int, accept: Bool, completion: (error: NSError?) -> Void) {
//        let parameters: [String : Any] = [
//            APIKey.FollowingRequests : [
//                APIKey.FollowingRequestId : id
//            ]
//        ]
//        makeRequest(.post, params: parameters, auth: true, router: .ReactToFollowRequest(accept: accept)) { data, error in
//            completion(error: error)
//        }
//    }
//    
//    static func fetchFollowers(completion: (followers: [User]?, error: NSError?) -> Void) {
//        makeRequest(.get, auth: true, router: .FetchFollowers) { data, error in
//            let followers: [User]? = data?[APIKey.Followers].array?.map { User(json: $0) }
//            completion(followers: followers, error: error)
//        }
//    }
//    
//    static func fetchFollowing(completion: (following: [User]?, error: NSError?) -> Void) {
//        makeRequest(.get, auth: true, router: .FetchFollowing) { data, error in
//            let following: [User]? = data?[APIKey.Following].array?.map { User(json: $0) }
//            completion(following: following, error: error)
//        }
//    }
    
    // MARK: - Search Requests
    
    static var searchRequests: [Request] = []
    
    /// Search all Courses in a given Term
    static func searchCourses(_ termSlug: String, query: String, completion: @escaping (_ courses: [CourseResult]?) -> Void) {
        
        searchRequests.forEach { $0.cancel() }
        searchRequests.removeAll()
        
        makeRequest(.get, auth: false, router: .searchCourses(term: termSlug, query: query), searchRequest: true) { data, error in
            var courses: [CourseResult]?
            if let array = data?["courses"].array {
                do {
                    let realm = try Realm()
                    try realm.write {
                        courses = array.map { CourseResult(id: $0["crse_id"].intValue, number: $0["catalog_number"].intValue, offerNumber: $0["course_offer_number"].intValue, title: $0["title_long"].stringValue, subject: $0["subject"].stringValue, termSlug: termSlug) }
                    }
                } catch let error {
                    print("Error occurred saving courses to realm: \(error)")
                }
            }
            DispatchQueue.main.async {
                completion(courses)
            }
        }
    }
    
    /// Search Users on RedRoster
    static func searchUsers(withQuery query: String, completion: @escaping (_ users: [User]?) -> Void) {
        
        searchRequests.forEach { $0.cancel() }
        searchRequests.removeAll()
        
        let query = query.replacingOccurrences(of: " ", with: "+")
        
        makeRequest(.get, auth: true, router: .searchUsers(query: query), searchRequest: true) { data, error in
            DispatchQueue.main.async {
                completion(data?["users"].array?.map { User(json: $0) })
            }
        }
    }
}
