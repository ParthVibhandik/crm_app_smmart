import Flutter
import UIKit
import CoreLocation
import flutter_background_service_ios

@main
@objc class AppDelegate: FlutterAppDelegate, CLLocationManagerDelegate {
  private let locationManager = CLLocationManager()
  private let channelName = "com.dhavalmodi.crm/location_service"
  private var backgroundChannel: FlutterMethodChannel?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        // Register the custom channel reliably
        let registrar = self.registrar(forPlugin: "LocationServicePlugin")
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar!.messenger())
        channel.setMethodCallHandler({ [weak self] (call, result) in
            self?.handleMethodCall(call: call, result: result)
        })

        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        // CRITICAL for background priority on iOS
        locationManager.showsBackgroundLocationIndicator = true 
        
        // Check if tracking was active before app was killed
        let isTrackingActive = UserDefaults.standard.bool(forKey: "isTrackingActive")
        if isTrackingActive {
            print("[AppDelegate] Persistence: Re-enabling Significant Location Monitoring on launch")
            locationManager.startMonitoringSignificantLocationChanges()
        }
        
        if let _ = launchOptions?[.location] {
            print("[AppDelegate] App launched/woken up by a location event")
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "enableSignificantLocationMonitoring" {
            self.toggleSignificantLocationMonitoring(enabled: true)
            result(true)
        } else if call.method == "disableSignificantLocationMonitoring" {
            self.toggleSignificantLocationMonitoring(enabled: false)
            result(true)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    private func toggleSignificantLocationMonitoring(enabled: Bool) {
        if enabled {
            print("[AppDelegate] Enabling Significant Location Monitoring")
            locationManager.startMonitoringSignificantLocationChanges()
            UserDefaults.standard.set(true, forKey: "isTrackingActive")
        } else {
            print("[AppDelegate] Disabling Significant Location Monitoring")
            locationManager.stopMonitoringSignificantLocationChanges()
            UserDefaults.standard.set(false, forKey: "isTrackingActive")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // This is called when the app is woken up by a significant location change.
        // The Flutter background service will also be triggered by the plugin.
        print("[AppDelegate] Significant location update received: \(locations.last?.coordinate.latitude ?? 0), \(locations.last?.coordinate.longitude ?? 0)")
    }
}
