//
//  ConnectionSettingsViewController.swift
//  HomeControl+
//
//  Created by Boleslav Glavatki on 29.09.24.
//

import UIKit
import CoreData
import CocoaMQTT
import MqttCocoaAsyncSocket

class ConnectionSettingsViewController: UIViewController, CocoaMQTTDelegate{
    
    
    @IBOutlet weak var goBackButton: UIButton!
    
    @IBOutlet weak var serverName: UITextField!
    
    @IBOutlet weak var serverToken: UITextField!
    
    @IBOutlet weak var ipAdresse: UITextField!
    
    @IBOutlet weak var portNummer: UITextField!
    
    @IBOutlet weak var userName: UITextField!
    
    @IBOutlet weak var userPasswort: UITextField!
    
    @IBOutlet var testVerbindungenCheck: UIView!
    
    @IBOutlet weak var testVerbindung: UIButton!
    
    @IBOutlet weak var speichernServerEinstellungen: UIButton!
    
    @IBOutlet weak var löschenEinstellungen: UIButton!
    
    @IBOutlet weak var checkImg: UIImageView!
    
    // Erstelle eine Instanz von CocoaMQTT
       var mqttClient: CocoaMQTT?
    
    
    
    
    
    
    
    
    @IBAction func goBackButtonTapped(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name("DataDidUpdate"), object: nil)
        dismiss(animated: true) {
               DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                   if let parentVC = self.presentingViewController as? ViewController {
                       parentVC.presentNewViewController()
                   }
               }
           }
    }

    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        // Alle Textfelder leeren
           serverName.text = ""
           serverToken.text = ""
           ipAdresse.text = ""
           portNummer.text = ""
           userName.text = ""
           userPasswort.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    //MARK: - Dismiss Keyboard
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true);
    }
    
        //MARK: - SaveButtonTapped                        **********************
    
    @IBAction func saveTapped(_ sender: Any) {
        if(ipAdresse.text! != "" && portNummer.text! != "" && serverName.text! != "" && serverToken.text! != "" && userName.text! != "" && userPasswort.text! != ""){
            
            // Dictionary mit Textfeldzuweisungen und Core Data Attributen
            let fieldToAttributeMapping: [UITextField: ReferenceWritableKeyPath<SCModel, String?>] = [
                serverName: \SCModel.s_name,
                serverToken: \SCModel.s_token,
                ipAdresse: \SCModel.s_ip,
                portNummer: \SCModel.s_port,
                userName: \SCModel.u_name,
                userPasswort: \SCModel.u_passwort
            ]
            print("SaveTapped")
            
            // Zugriff auf den ManagedObjectContext (viewContext)
            guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
                print("Fehler beim Zugriff auf den ViewContext.")
                return
            }
            
            // Neues `SCModel`-Objekt erstellen
            let newServerConnection = SCModel(context: context)
            
            
            
            
            // Überprüfe und weise Textfeld-Werte den Attributen zu
            for (textField, attributeKeyPath) in fieldToAttributeMapping {
                if let text = textField.text, !text.isEmpty {
                    newServerConnection[keyPath: attributeKeyPath] = text
                } else {
                    print("Fehler: Ein erforderliches Feld ist leer.")
                    return
                }
            }
            
            // Änderungen im Kontext speichern
            do {
                try context.save()
                print("Neues Objekt erfolgreich in Core Data gespeichert.")
            } catch {
                print("Fehler beim Speichern in Core Data: \(error.localizedDescription)")
            }
            
            NotificationCenter.default.post(name: Notification.Name("DataDidUpdate"), object: nil)
            
            dismiss(animated: true) {
               
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if let parentVC = self.presentingViewController as? ViewController {
                        parentVC.presentNewViewController()
                    }
                }
            }
        }else{
            showAlert(title: "Fehler", message: "Felder Portnummer, IP-Adresse, Tokem, Server Name, username, passwort dürfen nicht leer sein.")
        }
    }
    
    
    
    
    @IBAction func testTapped(_ sender: Any) {
        print("testConnectionTapped")
        getCoreData()
        print("Test Verbindung gestartet")
                
                // Trenne zuerst die Verbindung, falls bereits verbunden
                if mqttClient?.connState == .connected {
                    mqttClient?.disconnect()
                }else{
                    
                    //MARK: MQTT
                    
                    configureMQTTClient()
                    
                    // Stelle eine Verbindung zum MQTT-Server her
                    mqttClient?.connect()
                }
    }
    
    @IBAction func testConnection(_ sender: Any) {
        
    }
    
    
    
    
    
    func getCoreData(){
        print("Daten aus Core Data werden abgerufen...")
        
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            print("Fehler beim Zugriff auf den ViewContext.")
            return
        }
        
        let fetchRequest: NSFetchRequest<SCModel> = SCModel.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            if let firstResult = results as? [SCModel]{
                // Setze die Textfelder mit den Werten aus dem ersten Ergebnis
                print(firstResult)
                
                print("Daten erfolgreich abgerufen und in die Textfelder gesetzt.")
            } else {
                print("Keine Daten in Core Data gefunden.")
            }
        } catch {
            print("Fehler beim Abrufen der Daten aus Core Data: \(error.localizedDescription)")
        }
    }
    
    
    
    
    
    
    //MARK: MQTT
    
    @objc func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("Nachricht erfolgreich veröffentlicht mit ID: \(id)")
    }
    
    
    @objc func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        // Erfolgreich abonnierte Topics
           print("Erfolgreich abonnierte Topics: \(success)")
           
           // Topics, deren Anmeldung fehlgeschlagen ist
           if !failed.isEmpty {
               print("Fehlgeschlagene Anmeldung für folgende Topics: \(failed)")
           }
           
           // Führe hier zusätzliche Aktionen aus, z.B. UI-Updates oder das Verwalten der abonnierten Topics
    }
    
    @objc func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        // Zeige die abgemeldeten Topics an
            print("Von folgenden Topics erfolgreich abgemeldet: \(topics)")
            
            // Führe hier zusätzliche Aktionen aus, z.B. UI-Updates oder das Entfernen der Topics aus einer Liste
    }
    
    @objc func mqttDidPing(_ mqtt: CocoaMQTT) {
        // Protokolliere das Senden eines Ping
           print("Ping gesendet an den Server.")
    }
    
    
    
    
    
    @objc func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: (any Error)?) {
        if let error = err {
                // Zeige die Fehlermeldung an, wenn die Verbindung aufgrund eines Fehlers getrennt wurde
                print("Verbindung getrennt mit Fehler: \(error.localizedDescription)")
            } else {
                // Verbindung wurde ohne Fehler getrennt (z.B. Benutzer hat manuell getrennt)
                print("Verbindung zum MQTT-Server erfolgreich getrennt.")
                DispatchQueue.main.async {
                    self.checkImg.tintColor = UIColor.red
                }
            }
    }
    
    
    
    
    
    
    


    
    
    // Konfiguriere den MQTT-Client mit Host, Port und weiteren Einstellungen
        func configureMQTTClient() {
            // Erstelle eine eindeutige Client-ID für die Verbindung
            let clientID = "iOSClient-\(UUID().uuidString)"
            
            // Initialisiere den MQTT-Client mit dem Server-Host und Port
            // Zuerst testen ob das feld und portnummer nicht leer ist
            if(ipAdresse.text! != "" && portNummer.text! != ""){
                
                mqttClient = CocoaMQTT(clientID: clientID, host: ipAdresse.text!, port:  UInt16(portNummer.text!)!)
                
                // Optional: Setze Benutzername und Passwort (falls der Server dies erfordert)
                mqttClient?.username = nil   // Falls nicht erforderlich, auf nil setzen
                mqttClient?.password = nil   // Falls nicht erforderlich, auf nil setzen

                // Setze die Verbindungseigenschaften
                mqttClient?.keepAlive = 60   // Setze die Keep-Alive-Zeit in Sekunden
                mqttClient?.enableSSL = false // Falls der Server SSL erfordert, setze dies auf true

                // Setze das Delegate auf self, um MQTT-Ereignisse zu verarbeiten
                mqttClient?.delegate = self
            }else{
                showAlert(title: "Fehler", message: "Portnummer und IP-Adresse dürfen nicht leer sein.")
            }
            
        }
    
    //Popup Alert Message ausgeben
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    


    func sendMessageToMQTT(topic: String, message: String) {
        mqttClient?.publish(topic, withString: message, qos: .qos1)
    }

    @objc func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("Erfolgreich verbunden!")
        sendMessageToMQTT(topic: "test", message: "test message")
        //sendMessageToMQTT(topic: "lightValLux", message: "1") // Beispiel: LED ein
        // Ändere die Farbe auf Grün, um erfolgreiche Verbindung anzuzeigen
                DispatchQueue.main.async {
                    self.checkImg.tintColor = UIColor.green
                }
        // Abonniere das Topic "datenPunkt"
               mqtt.subscribe("datenPunkt")
    }

    func mqtt(_ mqtt: CocoaMQTT, didDisconnectWithError err: Error?) {
        DispatchQueue.main.async {
            self.checkImg.tintColor = UIColor.red
        }
        print("Verbindung getrennt: \(err?.localizedDescription ?? "kein Fehler")")
    }

    @objc func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        print("Nachricht erhalten auf Topic: \(message.topic), Nachricht: \(String(describing: message.string))")
        if message.topic == "datenPunkt" {
            // Verarbeite die Nachricht hier
            if let payload = message.string {
                print("Daten empfangen: \(payload)")
            }
        }
        
    }
    @objc func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("Nachricht erhalten auf Topic: \(message.topic), Nachricht: \(String(describing: message.string))")
    }

    func mqtt(_ mqtt: CocoaMQTT, didPing sent: Bool) {
        
    }

    @objc func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        print("Pong empfangen")
    }

    func mqtt(_ mqtt: CocoaMQTT, didReconnect resultCode: CocoaMQTTConnAck) {
        print("Verbindung wiederhergestellt: \(resultCode)")
    }
    
}
