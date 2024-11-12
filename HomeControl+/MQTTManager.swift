//
//  MQTTManager.swift
//  HomeControl+
//
//  Created by Boleslav Glavatki on 12.11.24.
//

// MQTTManager.swift

import Foundation
import CocoaMQTT

class MQTTManager: CocoaMQTTDelegate {
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: (any Error)?) {
        
    }
    
    
    static let shared = MQTTManager()
    
    var mqttClient: CocoaMQTT?
    
    private init() {
        // Initialisierung kann hier erfolgen, falls nötig
    }
    
    func configureClient(clientID: String, host: String, port: UInt16, username: String? = nil, password: String? = nil, enableSSL: Bool = false) {
        mqttClient = CocoaMQTT(clientID: clientID, host: host, port: port)
        mqttClient?.username = username
        mqttClient?.password = password
        mqttClient?.enableSSL = enableSSL
        mqttClient?.keepAlive = 60
        mqttClient?.delegate = self
    }
    
    func connect() -> Bool {
        return mqttClient?.connect() ?? false
    }
    
    func disconnect() {
        mqttClient?.disconnect()
    }
    
    func subscribe(topic: String) {
        mqttClient?.subscribe(topic)
    }
    
    func publish(topic: String, message: String, qos: CocoaMQTTQoS = .qos1) {
        mqttClient?.publish(topic, withString: message, qos: qos)
    }
    
    // MARK: - CocoaMQTTDelegate Methoden
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("MQTT: Erfolgreich verbunden!")
        // Beispiel: Sende eine Nachricht nach dem Verbinden
        publish(topic: "test", message: "Verbindung hergestellt")
        // Abonniere ein Standard-Topic, falls gewünscht
        subscribe(topic: "datenPunkt")
        
        // Optional: Aktualisiere UI-Elemente oder sende Notifications
        NotificationCenter.default.post(name: Notification.Name("MQTTConnected"), object: nil)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        print("MQTT: Nachricht erhalten auf Topic: \(message.topic), Nachricht: \(String(describing: message.string))")
        // Hier kannst du die empfangenen Nachrichten weiterverarbeiten
        NotificationCenter.default.post(name: Notification.Name("MQTTMessageReceived"), object: message)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        print("MQTT: Erfolgreich abonnierte Topics: \(success)")
        if !failed.isEmpty {
            print("MQTT: Fehlgeschlagene Anmeldung für folgende Topics: \(failed)")
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        print("MQTT: Von folgenden Topics erfolgreich abgemeldet: \(topics)")
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("MQTT: Ping gesendet an den Server.")
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        print("MQTT: Pong empfangen.")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didDisconnectWithError err: Error?) {
        if let error = err {
            print("MQTT: Verbindung getrennt mit Fehler: \(error.localizedDescription)")
        } else {
            print("MQTT: Verbindung zum Server erfolgreich getrennt.")
        }
        NotificationCenter.default.post(name: Notification.Name("MQTTDisconnected"), object: nil)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("MQTT: Nachricht erfolgreich veröffentlicht mit ID: \(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("MQTT: Nachricht veröffentlicht auf Topic: \(message.topic), Nachricht: \(String(describing: message.string))")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishComplete id: UInt16) {
        print("MQTT: Veröffentlichung der Nachricht mit ID \(id) abgeschlossen.")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        print("MQTT: Verbindungsstatus geändert zu: \(state)")
    }
}
