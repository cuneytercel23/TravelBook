//
//  ViewController.swift
//  TravelBook
//
//  Created by Cüneyt Erçel on 4.08.2022.
//

import UIKit
import MapKit      // Harita
import CoreLocation // Konum
import CoreData // 4. bölüm Veri kaydetme

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate { // Harita ve Konum delegatelerini ekledik

    //  1 Harita ve Kullanıcının konumunun yerini belirlemek
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager() // Kullanıcı yöneticisi tanımladık
    
    
    // 3 isimleri kaydetme için textfieldler ekledik ve bunları annotation kısmına yazdırıyorum 3.1 de .
    @IBOutlet weak var commentText: UITextField!
    
    @IBOutlet weak var nameText: UITextField!
    
    //4.2- 4.1 i yapmak için touchedcoordinatesden gelen latitude ve longitudeü bi değişkene atayıp, 4.1 de kullanıcaz setvalue kısmında.
    
   var choosenLatitude = Double()
    var choosenLongitude = Double()
    
    //7 Veriyi yollamak
    var selectedTitle = ""
    var selectedTitleId: UUID?
        
    
// 8.1 annotatiotn değişkenlerini oluşturuyoruz, iflerde kullanmak için
   var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotatitonLongitude = Double()
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1.1 bunlar klasik delegate işlemleri
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // Burada kullanıcı konumunun doğruluğu mevzusu var KCLL yazdıktansonra geliyo karşımıza seçenekelr, ve biz en iyisini seçtik. En iyisi cok enerji falan götürür ama en iyisini seçmemiz lazım cünkü, beğendiğimiz yerleri not etçez.
        locationManager.requestWhenInUseAuthorization() // buda kullanıcı sadece uygulamayı açarken konumunuz kullanılsın mı diye sor. Bu adım tamalandıktan sonra soldaki dosyalar kısmında infoya girip açıklama(babacım konumun lazım verdim) veriyoruz.
        locationManager.startUpdatingLocation() // bunuda kullanarak artık kullanıcının konumunu almaya başlamış olduk.
        
        
        
        //2 Pinleme - Uzun süreli basıldıktan sonra pinleme yapmak istiyoruz. O yüzden uılongpressgesture recognizer kullanıyoruz. Ama burda selector kısmında yazdığımız(objc fonksiyonu) chooselocationunda initializerınıda doldurduk ilk defa onunda sebebi: mapview.addgesture... yaptıktan sonra chooselocation içinde gesturerecognizere ulaşabildiğimden ötürü böyle yaptık.
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)) )
        
        gestureRecognizer.minimumPressDuration = 2 // 3 saniye basınca çalışır
        mapView.addGestureRecognizer(gestureRecognizer) // mapviewin üstüne ekledik, yani çalıştırdık gibi bişi.
        
        
        
        // 7.1
        if selectedTitle != "" {
            
            
            
            // 8 SEÇİLEN PİNİ GÖSTTERMEK - bu başlık şuan appdelegate yapıyoruz.
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            fetchRequest.returnsObjectsAsFaults = false
            let idString = selectedTitleId!.uuidString // bunda selectedtitleid olan şeyleri string olarak örneğin (1232312303-1232-123-) falan diye ceviriyor.
            fetchRequest.predicate = NSPredicate.init(format: "id = %@", idString) // burda da filtreledik sanırsam üsttekiyle(idstring olan) bağlantılı bu.
            
            do{
           let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                 
                    for result in results as! [NSManagedObject] {
                        if let title = result.value(forKey: "title") as? String{
                            annotationTitle = title // 8.1 de tanımladık burda kullandık
                            if let subtitle = result.value(forKey: "subtitle") as? String {
                                annotationSubtitle = subtitle
                                
                                if let latitude = result.value(forKey: "latitude") as? Double {
                                    annotationLatitude = latitude
                                    if let longitude = result.value(forKey: "longitude") as? Double {
                                        annotatitonLongitude = longitude
                                        
                                        
                                        // 8.2 Annotation tanımlama ve özelliklerini girme artık :D
                                        let annotation =  MKPointAnnotation() // anno oluşturma
                                        annotation.title = annotationTitle // anoonun başlığını bağdaştırma
                                        annotation.subtitle = annotationSubtitle // altbaşlığını bağdaştırma
                                        
                                        let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotatitonLongitude) // buda konumunu bağdaştırma
                                        
                                        annotation.coordinate = coordinate // buda üstteki cordinate i anotationa bağlama
                                        
                                        mapView.addAnnotation(annotation) // buda annotatitonu mapviewe bağlama :D
                                        nameText.text = annotationTitle     // seçilen yerde isim ve commment yerlerinde yazıcak şeyleri gösterme
                                        commentText.text = annotationSubtitle
                                        
                                        
                                        
                                        // 9 tableviewe basınca kaydettiğim yeri gösterme, + ya basınca olduğum yeri gösterme
                                        
                                        locationManager.stopUpdatingLocation()
                                        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                        let region = MKCoordinateRegion(center: coordinate, span: span)
                                        mapView.setRegion(region, animated: true)
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                    }
                                }
                            }
                            
                        }
                    
                    }
                    
                }
                
                
                
                
                
            }catch{
                print("error")
            }
            
            
            
          
            
        }else {
            // artı butona basınca olan
            
        }
    
    }
    
    
    // 11 PİN(ANNOTATİON) ÖZELLEŞTİRİLMESİ VE BİLGİ GİBİ BİR KUTUCUK EKLİYECEĞİZ 12 DE ONU NAVİGASYON YAPACAĞIZ.
  
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation { // burda anotation fonksiyon içinde yazılı olan annotation. Buranın anlamı eğer pin kullanıcının olduğu yeri gösteriyorsa nil ata. Yani kullanıcının olduğu yeri pinleyemiyoruz. boş bişi biraz.
            return nil
        }
        // bu ikiliyi yaparak özel pinimi oluşturmuş oldum.
        let reuseId = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true // burada annotation üzerinde ekstra böyle baloncuk gibi yeri göstermeye izin varmı? evet var dedim. aşağıda sağ tarafa bir button koyucam ve ona basınca da navigasyonu calısıtırıcam.
            pinView?.tintColor = UIColor.blue //burda da renk bağladık hesabı.
            
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure) // burada . detaildisclousru seçerek yuvarlak info veren i butonlar olur ya ondan oluşturduk.
            pinView?.rightCalloutAccessoryView = button // burda da pinin sağ kısmında bu butonu göster dedim.
            
            
            
        }else {
            
            pinView?.annotation = annotation
            
        }
        
        
    return pinView
    }
    
    
    
     // 2.1 objc fonksiyonu burada dokunulan noktayı, onu pine atamayı falan yapıyoruz.
    @objc func chooseLocation(gestureRecognizer:UILongPressGestureRecognizer) {
        
        if gestureRecognizer.state == .began { // eğer gesture recognizer işlemi başladıysa ..
            
            
            
            
            let touchedPoint = gestureRecognizer.location(in: self.mapView) // Dokunulmuş noktalar diye bişi açtım. Gesturerecognizerinın konumu dedim, in: mapviewin içinden.
            let touchedCoordinates = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView) // burdada dokunulan noktayı, self.mapviewdan al, coordinate e çevir. Convertten sonra initalizaerı bulmak zor ona dikkat et.
            
            // 2.2 pinleme demek anotation isim title gibi şeyler atıyoruz.
            
            let annotation = MKPointAnnotation() // Pinleme MKPointAnnotation() ile yapılıyor.
            annotation.coordinate = touchedCoordinates
            annotation.title = nameText.text // 3.1
            annotation.subtitle = commentText.text
            
            self.mapView.addAnnotation(annotation) // bunuda yaparak mapviewe eklemiş başlatmış olduk.
            
            //4.2.1
            choosenLatitude = touchedCoordinates.latitude
            choosenLongitude = touchedCoordinates.longitude
            
        }
        
        
    }
    
    
    
// 1.2 Didupdatelocation ile güncellenen lokasyonları biz dizi(CLLocation yazan yer, locations dizisi kendi verdi ismi) içerisine atıyoruz.
    
    
    // 9.2 normalde bu ifli kısım yoktu şimdi var
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if selectedTitle != "" { // 9.2 normalde bu ifli kısım yoktu şimdi var. nedenini anlamadım ama tableviewa basınca oradaki o ayarları göstermek istiyorz sanırım :(
        let location =  CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude) // Burada location diye isimi cllocationcoordinate2d e tanımladık çünkü enlem ve boylam kullanarak işlem yapıyoruzç latiude yani enlemine, güncellenen locations dizisisin ilk elemanını yani 0. elemanı verdik. sonra nokta coordiante nokta longitude diyerek, ilk elemanının kordinatının enlemini latitudeye atadık sonra aynısını boylam içinde yaptık.
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05) // SPAN zoom demek, eşittirden sonra span yazdım tek gelen şey buydu zaten. hem enlem hem boylam 0.1 verdik denemek için
        
        let region = MKCoordinateRegion(center: location, span: span) // Buda alan demek, haritada karşımıza çıkan 4gen alandan bahsediyoruz. Bununda mkcoordinateRegion kısmı ezber tabikide.
        mapView.setRegion(region, animated: true) // buda kullanılabilir olması için yapılıyor, çalıştırma yada kurma gibi bişi.
        }else{
            
        }
            
    }
    
    // 12 O bilgi butonuna tıkladıktan sonra navigasyon oluşturmamsal biraz ezber ve aşırı derecede kötü anlatıldı o yüzden ezber
    // calloutaccesory yazarak oradaki butona tıklanınca olan fonksiyon bu.
    
    // devamını ezbere yazdım çünkü anlamadım.
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if selectedTitle != "" {
            var requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotatitonLongitude) // burda latitude longitude başka değişkene atadık çünkü kullaancaz çok.
            
            CLGeocoder().reverseGeocodeLocation(requestLocation) { placemarks, error in
                if let placemark = placemarks{
                    if placemark.count > 0 {
                        let newPlacemark = MKPlacemark(placemark: placemark[0])
                        let item = MKMapItem (placemark: newPlacemark)
                        item.name = self.annotationTitle
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                        item.openInMaps(launchOptions: launchOptions)
                    }
                }
            }
            
            
            
            
        }
            
    }
    
    
    
    
    
    
    
    
    // 4 BUTONA BASINCA VERİ KAYDETME APP DELEGASYONU // önce import ediyoruz coredatayı
    @IBAction func saveButtonClicked(_ sender: Any) {
        // ilk 2 kod ezber gene contextin mantığını anlamak gerek ama
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
    
    //  4.1 bunu yapmadan önce entitileri oluşturuyoruz.
        // burası gene gelen yerleri kaydetmek için oluşturduğumuz yer
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        
        newPlace.setValue(nameText.text, forKey: "title") //nametext.texte gelen değeri title a adıyor.
        newPlace.setValue(commentText.text, forKey: "subtitle")
        newPlace.setValue(choosenLatitude, forKey: "latitude")
        newPlace.setValue(choosenLongitude, forKey: "longitude")
        newPlace.setValue(UUID(), forKey: "id")
        
        // klasik do try catch 4.3
        
        do {
            try context.save()
            print("success")
        }catch{
            print("error")
        }
        
        // 10 Notification Center ile bi önceki sayfaya geri gitmece
        
        NotificationCenter.default.post(name: NSNotification.Name("newPlace"), object: nil) // bunu yaparak anahtar kelime seçtik
        navigationController?.popViewController(animated: true) // bunuda yazarak anahtar kelime geldikten sonra beni bi önceki sayfaya gönderiyor.
        
        
        
        
    }
    
    
    
    }


    
    
    


