//
//  ListViewController.swift
//  TravelBook
//
//  Created by Cüneyt Erçel on 5.08.2022.
//

import UIKit
import CoreData

// 5 Table view açmak ve Sağ üste + butonu eklemece - önce tableview delegate ve datasource ekledik bu hemen aşağı
class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // 6.1 tanımlama
    var titleArray = [String]()
    
    var idArray = [UUID]()
    
    var choosenTitle = ""
    var choosenTitleId : UUID?

    
    

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 5.4 sağ üste buton ekleme
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        
        
// 5.1 klasik
        tableView.delegate = self
        tableView.dataSource = self
        
        

    
        
        
       getData()
    }
    
    // 10.1 we willappear açıyoruz 10 da yaptığımız bildirim merkezindeki kelimeyi burda da observer ile görüyoruz.
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newPlace"), object: nil)
    }

    
    
    
    
    
    // 6 Kaydettiğimiz verileri gösterme şekli
    @objc func  getData(){ // 10.1 ile bunu çevirdim objc fonksiyonuna
         let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            
            if results.count > 0 {
                
                self.titleArray.removeAll(keepingCapacity: false) // kaydedilenler dublike olmasın diye yaptığımız şey.
                self.idArray.removeAll(keepingCapacity: false)
                
                
                
                for result in results as! [NSManagedObject] {
                    
                    if let title = result.value(forKey: "title") as? String {
                        self.titleArray.append(title)
                    }
                    if let id = result.value(forKey: "id") as? UUID {
                        self.idArray.append(id)
                    }
                    tableView.reloadData()
                }
            }
            
            
            
            
        }catch{
            print("error")
        }
        
        
    }
    
    
    
    
    
    // 5.5 sağ üst butona basınca segue yapma
    
    @objc func addButtonClicked() {
        choosenTitle = ""
        performSegue(withIdentifier: "toViewController", sender: nil)
    }
    
    
    
    
// 5.2 numbersofrow ve cellfor row at klasikleri
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count // 6 nın son kısmı
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell() // hücre oluşturduk ve altta test ismini verdik en başta
        cell.textLabel?.text = titleArray[indexPath.row] // 6 nın son kısmı
        return cell
        
        
    }
    // 7.3-(7.2 yukarda choosen tanımlamaları) 7.3 didselect row ile prepare for segue yani segue yapmadan önce bunları yap. // önce addbuttonclicked kısmına gidip choosentitle = "" yapıyorum.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        choosenTitle = titleArray[indexPath.row]
        choosenTitleId = idArray[indexPath.row]
        performSegue(withIdentifier: "toViewController", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toViewController" {
            let destinationVC = segue.destination as! ViewController // bunu yaparak viewcontrolera ulaşabiliyorum.
            
            destinationVC.selectedTitle = choosenTitle // bi önceki kodla viewcontrollara ulaştım ve buradaki chooesnı oradaki selecteda eşitledim şimdi view controllera gidip son işlemi yapıcam
            destinationVC.selectedTitleId = choosenTitleId 
            
            
            
        }
    }
    
    
    
}
