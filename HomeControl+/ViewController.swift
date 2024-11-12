//
//  ViewController.swift
//  HomeControl+
//
//  Created by Boleslav Glavatki on 29.09.24.
//

import UIKit
import Charts
import CoreData
import CocoaMQTT



class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var firstResult: [SCModel] = [] // Core Data Ergebnisse
    var selectedModel: SCModel? // Speichert das ausgewählte Modell
    
    @IBOutlet weak var tabelle: UITableView!
    @IBOutlet weak var addButton: UIButton!
    
    func presentNewViewController() {
        // Hier definierst du die Logik, um einen neuen ViewController zu präsentieren
        if let newVC = storyboard?.instantiateViewController(withIdentifier: "NewViewControllerID") {
            present(newVC, animated: true, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad() // Wichtiger Aufruf als Erstes in viewDidLoad
        
        addButton.setTitle("", for: .normal) // Setze den Button-Titel auf leer
        tabelle.delegate = self
        tabelle.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(dataDidUpdate), name: Notification.Name("DataDidUpdate"), object: nil)
        
        getDataFromCore() // Core Data Daten abrufen
    }
    
    @objc func dataDidUpdate() {
           // Core Data erneut laden
           getDataFromCore()
           // Tabelle aktualisieren
           tabelle.reloadData()
       }

       deinit {
           // Beobachter entfernen
           NotificationCenter.default.removeObserver(self, name: Notification.Name("DataDidUpdate"), object: nil)
       }
    
    

    @IBAction func addButtonTapped(_ sender: Any) {
        if self.presentedViewController == nil {
                performSegue(withIdentifier: "mitDemServerVerbinden", sender: self)
            } else {
                print("Ein View Controller ist bereits präsent.")
            }
    }
    
    
    
    
    
    
    // Funktion zum Abrufen der Daten aus Core Data
    func getDataFromCore() {
        print("Daten aus Core Data werden abgerufen...")

        // Zugriff auf den ManagedObjectContext (viewContext)
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            print("Fehler beim Zugriff auf den ViewContext.")
            return
        }

        let fetchRequest: NSFetchRequest<SCModel> = SCModel.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false // Verhindert, dass die Objekte als "Faults" zurückgegeben werden

        do {
            // Daten aus Core Data abrufen
            let results = try context.fetch(fetchRequest)
            
            // Überprüfen, ob Ergebnisse gefunden wurden und zuweisen
            if !results.isEmpty {
                firstResult = results // Ergebnisse zuweisen
                print("Daten erfolgreich abgerufen: \(firstResult)")
                
                // Tabelle mit den neuen Daten aktualisieren
                tabelle.reloadData()
            } else {
                print("Keine Daten in Core Data gefunden.")
            }
        } catch {
            print("Fehler beim Abrufen der Daten aus Core Data: \(error.localizedDescription)")
        }
    }
    
    
    
    
    
    
    

    // MARK: - UITableViewDataSource Methoden
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return firstResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Verwende den Identifier, der im Storyboard für die Zelle festgelegt ist
        let cell = tableView.dequeueReusableCell(withIdentifier: "connection", for: indexPath) as! CustomViewCellTableViewCell
        let scModel = firstResult[indexPath.row]
        
        // Setze den Text der Zelle mit einem Attribut aus dem SCModel
        cell.serverNameLabel.text = scModel.s_name ?? "Keine Name"
        cell.countLabel?.text = "\(indexPath.row + 1)"
        cell.checkmarkUIImage.tintColor = connection() ?? UIColor.red// Beispielhafte Farbänderung
                
        return cell
    }
    func connection()->UIColor{
        return UIColor.green;
    }

    // MARK: - UITableViewDelegate Methoden
    
    // Diese Methode wird aufgerufen, wenn eine Zeile ausgewählt wird
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Speichere das ausgewählte Objekt
        selectedModel = firstResult[indexPath.row]
        
        // Starte die Navigation zum Detail-ViewController
        performSegue(withIdentifier: "goToTheWidget", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            
            // Zugriff auf den ManagedObjectContext (viewContext)
            guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
                print("Fehler beim Zugriff auf den ViewContext.")
                return
            }
            context.delete(firstResult[indexPath.row])
            do{
                try context.save()
            }catch let error as NSError{
                print("Could not save.... \(error)")
            }
            firstResult.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .top)
        }
    }
    
    // Bereite die Übergabe der Daten an den Ziel-ViewController vor
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToTheWidget" {
            if let detailVC = segue.destination as? SmartControlViewController {
                // Übergib das ausgewählte SCModel-Objekt an den Detail-ViewController
                detailVC.model = selectedModel
            }
        }
    }
}



