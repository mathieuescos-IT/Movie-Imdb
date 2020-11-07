//
//  ViewController.swift
//  EvalMovie
//
//  Created by Mathieu on 05/11/2020.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var table: UITableView!
    @IBOutlet var field: UITextField!

    var movies = [Movie]()

    override func viewDidLoad() {
        super.viewDidLoad()
        table.register(MovieTableViewCell.nib(), forCellReuseIdentifier: MovieTableViewCell.identifier)
        table.delegate = self
        table.dataSource = self
        field.delegate = self
        
        getMovies()
    }

    // Field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchMovies()
        return true
    }

    func searchMovies() {
        field.resignFirstResponder()
        
        movies.removeAll()

        guard let text = field.text, !text.isEmpty else {
            return getMovies()
        }

        let query = text.replacingOccurrences(of: " ", with: "%20")

        movies.removeAll()

        let url = URL(string: "https://www.omdbapi.com/?s=\(query)&apikey=e238f827")!

        URLSession.shared.dataTask(with: url, completionHandler: { data,_, error in

            if let error = error {
                print("Error occured : \(error)")
            }

            var result: MovieResult?
            do {
                let decoder = JSONDecoder()
                let data = try Data(contentsOf: url)
                result = try decoder.decode(MovieResult.self, from: data)
                
                if let finalResult = result {
                    let newMovies = finalResult.Search
                    self.movies.append(contentsOf: newMovies)

                    DispatchQueue.main.async {
                        self.table.reloadData()
                    }
                }
            }
            catch {
                print("error")
            }

        }).resume()

    }
    
    func getMovies() {
        field.resignFirstResponder()

        let url = URL(string: "https://www.omdbapi.com/?s=Blade&apikey=e238f827")!

        URLSession.shared.dataTask(with: url, completionHandler: {data,_,error in

            if let error = error {
                print("Error occured : \(error)")
            }
            
            var result: MovieResult?
            
            do {
                let decoder = JSONDecoder()
                let data = try Data(contentsOf: url)
                result = try decoder.decode(MovieResult.self, from: data)
                
                if let finalResult = result {
                    let newMovies = finalResult.Search
                    self.movies.append(contentsOf: newMovies)

                    DispatchQueue.main.async {
                        self.table.reloadData()
                }
            }
            }
            catch {
                print("error")
            }

        }).resume()
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier, for: indexPath) as! MovieTableViewCell
        cell.configure(with: movies[indexPath.row])
        return cell
    }

}

struct MovieResult: Codable {
    let Search: [Movie]
}

struct Movie: Codable {
    let Title: String
    let Year: String
    let imdbID: String
    let type: String
    let Poster: String

    enum CodingKeys: String, CodingKey {
        case Title, Year, imdbID, type = "Type", Poster
    }
    
    init(Title: String, Year: String, Poster: String, imdbID: String, type: String) {
        self.Title = Title
        self.Year = Year
        self.Poster = Poster
        self.imdbID = imdbID
        self.type = type
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.Title = try container.decode(String.self, forKey: .Title)
        self.Year = try container.decode(String.self, forKey: .Year)
        self.Poster = try container.decode(String.self, forKey: .Poster)
        self.imdbID = try container.decode(String.self, forKey: .imdbID)
        self.type = try container.decode(String.self, forKey: .type)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.Title, forKey: .Title)
        try container.encode(self.Year, forKey: .Year)
        try container.encode(self.Poster, forKey: .Poster)
        try container.encode(self.imdbID, forKey: .imdbID)
        try container.encode(self.type, forKey: .type)
    }
}

