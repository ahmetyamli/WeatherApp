//
//  SaveLocationsViewController.swift
//  WeatherApp
//
//  Created by Ahmet on 6.07.2023.
//

import UIKit
import MapKit
import CoreLocation
import CoreData


class SaveLocationsViewController: UIViewController,MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var myButton: UIButton!
    @IBOutlet weak var baslıkTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    var secilenLatitude = Double()
    var secilenLongitude = Double()
    
    let annotation = MKPointAnnotation()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapKonumAl()
        buttonGizle()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(konumSec(gestureRecognizer: )))
        gestureRecognizer.minimumPressDuration = 1
        mapView.addGestureRecognizer(gestureRecognizer)
        mapView.removeAnnotation(annotation)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
               view.addGestureRecognizer(tapGesture)
       
    
        
        
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
           
           view.endEditing(true)
       }
    
    func mapKonumAl () {
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print(locations[0].coordinate.latitude)
        //print(locations[0].coordinate.longitude)//anlık konumları alıyoruz böyle
        
    }
    
    
    
    @objc func konumSec(gestureRecognizer : UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began{
            let dokunulanNokta = gestureRecognizer.location(in: mapView)
            let dokunulanKoordinat = mapView.convert(dokunulanNokta, toCoordinateFrom: mapView)
            
            
            annotation.coordinate = dokunulanKoordinat
            annotation.title = baslıkTextField.text
            mapView.addAnnotation(annotation)
            
            secilenLatitude = dokunulanKoordinat.latitude
            secilenLongitude = dokunulanKoordinat.longitude
            
            buttonGizle()
        
        }
        
    }
    
    @IBAction func kaydetTiklandi(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let yeniYer = NSEntityDescription.insertNewObject(forEntityName: "Yer", into: context)
        
        yeniYer.setValue(baslıkTextField.text, forKey: "kayitIsmi")
        yeniYer.setValue(secilenLatitude, forKey: "latitude")
        yeniYer.setValue(secilenLongitude, forKey: "longitude")
        yeniYer.setValue(UUID(), forKey: "id")
        
        // Sırayı kaydet
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "sira", ascending: true)]
        
        do {
            let results = try context.fetch(fetchRequest)
            let maxSira = results.count
            yeniYer.setValue(maxSira, forKey: "sira")
        } catch {
            print("Hata: Sıra kaydedilirken hata oluştu - \(error)")
        }
        
        do {
            try context.save()
            print("kayıt edildi")
            baslıkTextField.text = ""
            baslıkTextField.placeholder = "Kaydedildi lütfen geri çıkın"
            if let haftalikVC = self.navigationController?.viewControllers.first(where: { $0 is haftalikViewController }) as? haftalikViewController {
                     haftalikVC.coreDataVeriCekimi()
                     haftalikVC.tableView.reloadData()
                 }
                 
                 self.navigationController?.popViewController(animated: true)
            
        } catch {
            print("hata")
        }
        
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "haftalikViewController") as! haftalikViewController
        
//        self.navigationController?.pushViewController(vc, animated: true)
        
        
        
    }
    
    
    func buttonGizle() {
        if let text = baslıkTextField.text, !text.isEmpty && secilenLatitude != 0 {
            myButton.isEnabled = true
        } else {
            myButton.isEnabled = false
        }
    }
        
    
        
   
}
