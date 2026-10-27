import Foundation
import Combine
import CoreBluetooth

/// Native BLE transport for the SunRise alarm. Uses Apple's CoreBluetooth API;
/// no browser Bluetooth API or third-party browser is involved.
final class SunRiseBluetooth: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @Published private(set) var status = "Bluetooth en attente"
    @Published private(set) var isScanning = false
    @Published private(set) var isConnected = false
    @Published private(set) var devices: [CBPeripheral] = []
    @Published private(set) var details = ""

    private var central: CBCentralManager!
    private var peripheral: CBPeripheral?
    private var characteristics: [String: CBCharacteristic] = [:]
    private let serviceAE30 = CBUUID(string: "AE30")
    private let serviceAE3A = CBUUID(string: "AE3A")
    private let writeUUID = CBUUID(string: "AE10")
    private let notifyUUIDs: [CBUUID] = ["AE02", "AE04", "AE05", "AE10", "AE3C"].map { CBUUID(string: $0) }

    override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: .main)
    }

    func scan() {
        guard central.state == .poweredOn else {
            status = "Activez le Bluetooth de l’iPhone/iPad."
            return
        }
        devices.removeAll()
        isScanning = true
        status = "Recherche du réveil…"
        central.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        DispatchQueue.main.asyncAfter(deadline: .now() + 12) { [weak self] in
            guard let self, self.isScanning else { return }
            self.central.stopScan()
            self.isScanning = false
            self.status = self.devices.isEmpty ? "Aucun appareil détecté. Rapprochez le réveil et réessayez." : "Sélectionnez votre réveil."
        }
    }

    func connect(_ device: CBPeripheral) {
        central.stopScan()
        isScanning = false
        status = "Connexion à \(device.name ?? "réveil")…"
        peripheral = device
        device.delegate = self
        central.connect(device, options: nil)
    }

    func disconnect() {
        if let peripheral { central.cancelPeripheralConnection(peripheral) }
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn: status = "Bluetooth prêt"
        case .poweredOff: status = "Bluetooth désactivé"
        case .unauthorized: status = "Autorisez Bluetooth dans Réglages iOS"
        case .unsupported: status = "Bluetooth LE non pris en charge"
        case .resetting: status = "Bluetooth redémarre…"
        default: status = "Bluetooth indisponible"
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard !devices.contains(where: { $0.identifier == peripheral.identifier }) else { return }
        let advertisedName = peripheral.name ?? advertisementData[CBAdvertisementDataLocalNameKey] as? String
        // Show nearby peripherals because some alarm firmware advertises no service UUID.
        if let advertisedName, !advertisedName.isEmpty {
            devices.append(peripheral)
            status = "\(devices.count) appareil(s) détecté(s). Choisissez le réveil."
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        isConnected = true
        status = "Connecté à \(peripheral.name ?? "réveil"). Recherche des services…"
        details = "Connexion BLE établie.\n"
        peripheral.discoverServices([serviceAE30, serviceAE3A, CBUUID(string: "AF30")])
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        isConnected = false
        status = "Échec de connexion : \(error?.localizedDescription ?? "inconnu")"
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        isConnected = false
        characteristics.removeAll()
        status = error.map { "Déconnecté : \($0.localizedDescription)" } ?? "Réveil déconnecté"
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error { append("Erreur services : \(error.localizedDescription)"); return }
        for service in peripheral.services ?? [] {
            append("Service : \(service.uuid.uuidString)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error { append("Erreur caractéristiques : \(error.localizedDescription)"); return }
        for characteristic in service.characteristics ?? [] {
            let key = characteristic.uuid.uuidString.uppercased()
            characteristics[key] = characteristic
            append("\(key) — \(characteristic.properties)")
            if notifyUUIDs.contains(characteristic.uuid) && (characteristic.properties.contains(.notify) || characteristic.properties.contains(.indicate)) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
        if characteristics[writeUUID.uuidString] != nil {
            status = "Réveil connecté. Commandes disponibles."
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error { append("Lecture/notification \(characteristic.uuid): \(error.localizedDescription)"); return }
        guard let data = characteristic.value else { return }
        append("Réponse \(characteristic.uuid): " + data.map { String(format: "%02X", $0) }.joined(separator: " "))
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        append(error.map { "Écriture échouée : \($0.localizedDescription)" } ?? "Écriture confirmée : \(characteristic.uuid)")
    }

    func inspect() {
        guard let peripheral else { return }
        for service in peripheral.services ?? [] { peripheral.discoverCharacteristics(nil, for: service) }
    }

    func setColor(_ value: UInt8) { send(prefix: 0x0D, opcode: [0x01, 0x80], data: [value], label: "Couleur") }
    func setBrightness(_ value: UInt8) { send(prefix: 0x0E, opcode: [0x01, 0x86], data: [0x01, value], label: "Luminosité") }
    func setVolume(_ value: UInt8) { send(prefix: 0x0E, opcode: [0x01, 0x87], data: [0x01, value], label: "Volume") }
    func sendHeartbeat() {
        sendRaw([0xBB,0x0C,0,0,0,0,0,1,1,0x60,0,0xAA], label: "Heartbeat")
    }

    private func send(prefix: UInt8, opcode: [UInt8], data: [UInt8], label: String) {
        // Packet structure mirrors the commands already used by the web prototype.
        let packet = [UInt8]([0xBB, prefix, 0, 0, 0, 0, 0, 1] + opcode + data + [0x00, 0xAA])
        sendRaw(packet, label: label)
    }

    private func sendRaw(_ bytes: [UInt8], label: String) {
        guard let peripheral, peripheral.state == .connected else { status = "Connectez le réveil avant d’envoyer une commande."; return }
        guard let characteristic = characteristics[writeUUID.uuidString], characteristic.properties.contains(.writeWithoutResponse) || characteristic.properties.contains(.write) else {
            status = "Caractéristique d’écriture AE10 indisponible."
            return
        }
        let type: CBCharacteristicWriteType = characteristic.properties.contains(.write) ? .withResponse : .withoutResponse
        peripheral.writeValue(Data(bytes), for: characteristic, type: type)
        append("\(label) envoyé : " + bytes.map { String(format: "%02X", $0) }.joined(separator: " "))
    }

    private func append(_ line: String) {
        details = (details + line + "\n")
        if details.count > 9000 { details = String(details.suffix(7000)) }
    }
}
