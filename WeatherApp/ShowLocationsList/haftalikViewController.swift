//
//  haftalikViewController.swift
//  WeatherApp
//
//  Created by Ahmet on 4.07.2023.
//

import UIKit
import CoreData

struct CityModule
{
    
    
    var latitude : Double?
    var longitude : Double?
    var id : UUID?
    var isim : String?
    var sira: Int?
    
}

class haftalikViewController: UIViewController
{
    

   
 
    
    var list: [CityModule] = []
    var filteredList: [CityModule] = []
    var selectedCity : CityModule?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    var searchController: UISearchController!
    var weatherData: Empty?
    
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        coreDataVeriCekimi()
  
        
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        searchBar.placeholder = "Ara..."
        
        navigationItem.rightBarButtonItems = [addButton, editButton]
        let cellNib = UINib(nibName: "SehirTableViewCell", bundle: nil)
        tableView.register(cellNib , forCellReuseIdentifier: "tableCell")


        
    }
    

    @objc func addButtonTapped()
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SaveLocationsViewController") as! SaveLocationsViewController
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc func editButtonTapped()
    {
        if searchBar.isFirstResponder
        {
            searchBar.text = ""
            searchBar.resignFirstResponder() // Klavyeyi kapat
            filteredList = list
            tableView.reloadData()
        }
        
        if tableView.isEditing
        {
            tableView.isEditing = false
        } else
        {
            tableView.isEditing = true
            editButtonItem.title = "Done"
        }
    }
    

    
   //CORE DATA VERİ ÇEKİMİ
    
    
    func coreDataVeriCekimi()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Yer")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "sira", ascending: true)]

        do
        {
            let sonuclar = try context.fetch(fetchRequest)

            list = [CityModule]()

            for (_, sonuc) in sonuclar.enumerated()
            {
                if let latitude = sonuc.value(forKey: "latitude") as? Double,
                   let longitude = sonuc.value(forKey: "longitude") as? Double,
                   let sira = sonuc.value(forKey: "sira") as? Int,
                   let id = sonuc.value(forKey: "id") as? UUID,
                   let isim = sonuc.value(forKey: "kayitIsmi") as? String
                {

                    list.append(CityModule(latitude: latitude, longitude: longitude, id: id, isim: isim, sira: sira))
                }
            }
            // sıralama yapmayı sağlar
            filteredList = list.sorted(by: { c1, c2 in
                c1.sira ?? 0 < c2.sira ?? 0
            })

        } catch
        {
            print("Hata: \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    


 }


//TABLE VİEW FONKSİYONLARI


extension haftalikViewController : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return filteredList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var stringLongitude = ""
        var stringLatitude = ""
        
        if let doubleLatitude = filteredList[indexPath.row].latitude
        {
            stringLatitude = String(doubleLatitude)
        }
        if let doubleLongitude = filteredList[indexPath.row].longitude
        {
            stringLongitude = String(doubleLongitude)
        }
       
        
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! SehirTableViewCell
        cell.sehirAdıLabel.text = filteredList[indexPath.row].isim
        cell.dereceLabel.text = "lat: " + String(stringLatitude.prefix(5))
        cell.konumLabel.text = "long: " + String(stringLongitude.prefix(5))
        
        


       

        return cell
    }

    
   
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        let movedCity = list.remove(at: sourceIndexPath.row)
            list.insert(movedCity, at: destinationIndexPath.row)
            self.filteredList = list
        updateData()
    }
    
    
  
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
            
        selectedCity = filteredList[indexPath.row]
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "InformationViewController") as! InformationViewController
        vc.cityModule = selectedCity
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
          // İstediğiniz hücre yüksekliğini burada döndürün
          return 70.0 // Örneğin 60 birimlik bir yükseklik
    }
    
    func tableView(_ tableView: UITableView, widthForRowAt indexPath: IndexPath) -> CGFloat
    {
           // İstediğiniz genişlik değerini belirleyin
           let cellWidth: CGFloat = 400
           return cellWidth
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete
        {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
            let uuidString = list[indexPath.row].id!
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString as CVarArg)
            fetchRequest.returnsObjectsAsFaults = false
            
            do
            {
                let sonuclar = try context.fetch(fetchRequest)
                if sonuclar.count > 0
                {
                    for sonuc in sonuclar as! [NSManagedObject]
                    {
                        if let id = sonuc.value(forKey: "id") as? UUID
                        {
                            if id == list[indexPath.row].id
                            {
                                context.delete(sonuc)
                                list.remove(at: indexPath.row)
                                self.filteredList = list
                                tableView.reloadData()
                                do
                                {
                                    try context.save()
                                } catch
                                {
                                    print("Hata: Veri kaydedilemedi.")
                                }
                                break
                            }
                        }
                    }
                }
            } catch
            {
                print("Hata: Veriler getirilemedi.")
            }
        }
    }
    
    func updateData()
    {
        
        for (i,value) in filteredList.enumerated() {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                      let context = appDelegate.persistentContainer.viewContext
           
                      // Verileri güncelleyeceğiniz Core Data varlık (entity) örneğini alın
                      let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
                
           
            fetchRequest.predicate = NSPredicate(format: "id = %@", value.id! as CVarArg)
                      fetchRequest.returnsObjectsAsFaults = false
           
                      do
                      {
                          let results = try context.fetch(fetchRequest)
                          if let entity = results.first as? NSManagedObject {
                              // Core Data'da ilgili varlık (entity) bulundu
                              // Yeni sıralama bilgilerini güncelleyin ve kaydedin
                              entity.setValue(i, forKey: "sira") // "sira" ismini kullanarak sıra değerini güncelleyin
           
                              try context.save() // Güncelleme işlemini kaydedin
                          }
                      } catch
                      {
                          print("Hata: Veriler güncellenirken hata oluştu - \(error)")
                      }
            
            
        }
        
    }


    
}


extension haftalikViewController: UISearchBarDelegate
{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if searchText != ""
        {
            filteredList = list.filter { $0.isim?.range(of: searchText, options: .caseInsensitive) != nil }
            tableView.reloadData()
        }else
        {
            self.filteredList = list
            tableView.reloadData()
        }
    }
}
