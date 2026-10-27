import SwiftUI

@main
struct SunRiseApp: App {
    @StateObject private var bluetooth = SunRiseBluetooth()

    var body: some Scene {
        WindowGroup {
            ContentView(bluetooth: bluetooth)
                .preferredColorScheme(.dark)
        }
    }
}

struct ContentView: View {
    @ObservedObject var bluetooth: SunRiseBluetooth
    @State private var color = 128.0
    @State private var brightness = 80.0
    @State private var volume = 65.0

    var body: some View {
        NavigationStack {
            Form {
                Section("Connexion") {
                    HStack {
                        Circle().fill(bluetooth.isConnected ? .green : .gray).frame(width: 10, height: 10)
                        Text(bluetooth.status).font(.subheadline)
                    }
                    Button(bluetooth.isScanning ? "Recherche en cours…" : "Rechercher le réveil") {
                        bluetooth.scan()
                    }.disabled(bluetooth.isScanning || bluetooth.isConnected)
                    if bluetooth.isConnected {
                        Button("Déconnecter", role: .destructive) { bluetooth.disconnect() }
                        Button("Lire les caractéristiques") { bluetooth.inspect() }
                    }
                    if !bluetooth.devices.isEmpty {
                        ForEach(bluetooth.devices, id: \.identifier) { device in
                            Button(device.name ?? "Réveil Bluetooth") { bluetooth.connect(device) }
                        }
                    }
                }
                Section("Lumière") {
                    VStack(alignment: .leading) {
                        LabeledContent("Couleur", value: "\(Int(color))")
                        Slider(value: $color, in: 0...255, step: 1)
                        Button("Appliquer la couleur") { bluetooth.setColor(UInt8(color)) }
                            .disabled(!bluetooth.isConnected)
                    }
                    VStack(alignment: .leading) {
                        LabeledContent("Luminosité", value: "\(Int(brightness)) %")
                        Slider(value: $brightness, in: 0...100, step: 1)
                        Button("Appliquer la luminosité") { bluetooth.setBrightness(UInt8(brightness)) }
                            .disabled(!bluetooth.isConnected)
                    }
                }
                Section("Son") {
                    LabeledContent("Volume", value: "\(Int(volume)) %")
                    Slider(value: $volume, in: 0...100, step: 1)
                    Button("Appliquer le volume") { bluetooth.setVolume(UInt8(volume)) }
                        .disabled(!bluetooth.isConnected)
                }
                Section("Diagnostic") {
                    Text(bluetooth.details.isEmpty ? "Les réponses du réveil apparaîtront ici." : bluetooth.details)
                        .font(.system(.caption, design: .monospaced))
                        .textSelection(.enabled)
                    Button("Envoyer le heartbeat") { bluetooth.sendHeartbeat() }
                        .disabled(!bluetooth.isConnected)
                }
            }
            .navigationTitle("SunRise")
            .tint(Color(red: 1, green: 0.61, blue: 0.35))
        }
    }
}
