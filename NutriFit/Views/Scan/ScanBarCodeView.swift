//
//  ScanBarCodeView.swift
//  NutriFit
//
//  Created by Maxence Walter on 17/10/2024.
//

import SwiftUI
import AVFoundation

struct ScanBarCodeView: View {
    @State private var scannedCode: String = ""
    @State private var isScanning: Bool = false
    @State private var isCode: Bool = false
    @State private var isScanView: Bool = true
    
    // Page pour scanner un produit
    var body: some View {
        ZStack {
            Color(red: 34 / 255, green: 34 / 255, blue: 34 / 255)
                .ignoresSafeArea()
            
            if isScanning {
                BarcodeScannerView(scannedCode: $scannedCode, isScanning: $isScanning, isCode: $isCode)
                    .edgesIgnoringSafeArea(.all)
            }
            
            VStack {
                
                Spacer()
                
                Button(action: {
                    isScanning = true
                }) {
                    Text("Scanner")
                        .font(.headline)
                        .foregroundColor(Color(red: 34 / 255, green: 34 / 255, blue: 34 / 255))
                        .frame(width: 110, height: 40)
                        .background(Color.white)
                        .cornerRadius(10)
                }
                .padding(.bottom, 15)
            }
        }
        .onAppear {
            checkCameraAuthorizationStatus()
        }
        .onChange(of: scannedCode) {
                isCode = true
        }
        .navigationDestination(isPresented: $isCode) {
            ProductScanView(barCode: scannedCode)
        }
    }
    
    // Fonction pour demander l'accès à la caméra
    func checkCameraAuthorizationStatus() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if !granted {
                    print("Accès caméra refusé")
                }
            }
        case .restricted, .denied:
            print("Accès caméra restreint ou refusé")
        case .authorized:
            break
        @unknown default:
            fatalError("Statut caméra inconnu")
        }
    }
}

// Structure pour afficher la caméra
struct BarcodeScannerView: UIViewControllerRepresentable {
    @Binding var scannedCode: String
    @Binding var isScanning: Bool
    @Binding var isCode: Bool

    func makeUIViewController(context: Context) -> BarcodeScannerViewController {
        let viewController = BarcodeScannerViewController()
        viewController.delegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_ uiViewController: BarcodeScannerViewController, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, BarcodeScannerViewControllerDelegate {
        
        var parent: BarcodeScannerView

        init(_ parent: BarcodeScannerView) {
            self.parent = parent
        }

        func didFindCode(_ code: String) {
            parent.scannedCode = code
            parent.isScanning = false
            parent.isCode = false
        }
    }
}

// Class pour rechercher le code bar à la caméra
class BarcodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    weak var delegate: BarcodeScannerViewControllerDelegate?
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("Votre appareil ne prend pas en charge la caméra.")
            return
        }

        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("Impossible d'accéder à la caméra.")
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            print("Impossible d'ajouter l'entrée caméra à la session.")
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean13, .ean8, .qr, .code128]
        } else {
            print("Impossible d'ajouter la sortie de métadonnées.")
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }

    // Fonction pour récupérer le numéro du code bar
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let code = readableObject.stringValue else { return }

            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            DispatchQueue.main.async { [self] in
                self.delegate?.didFindCode(code)
            }
        }
    }
    override var prefersStatusBarHidden: Bool { return true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .portrait }
}

protocol BarcodeScannerViewControllerDelegate: AnyObject {
    func didFindCode(_ code: String)
}
