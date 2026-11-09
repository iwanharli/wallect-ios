import SwiftUI
import AVFoundation

struct QRScannerView: View {
    @Binding var isPresented: Bool
    @State private var scanResult: String?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                CodeScannerView(codeTypes: [.qr]) { result in
                    switch result {
                    case .success(let code):
                        self.handleScan(id: code)
                    case .failure(let error):
                        self.alertMessage = "Scanner Error: \(error.localizedDescription)"
                        self.showAlert = true
                    }
                }
                .ignoresSafeArea()
                
                // Scanner Overlay
                VStack {
                    Text("Pindai Kode QR")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top, 40)
                    
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Theme.accent, lineWidth: 2)
                        .frame(width: 250, height: 250)
                        .overlay(
                            Image(systemName: "viewfinder")
                                .font(.system(size: 200, weight: .ultraLight))
                                .foregroundColor(Theme.accent.opacity(0.3))
                        )
                    
                    Spacer()
                    
                    Text("Arahkan kamera ke layar dashboard web Wallect")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.bottom, 40)
                }
            }
            .navigationTitle("Scan Login")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Selesai") {
                        isPresented = false
                    }
                    .foregroundColor(Theme.accent)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("QR Login"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func handleScan(id: String) {
        // Simple UUID validation
        guard UUID(uuidString: id) != nil else {
            alertMessage = "Format Kode QR tidak valid"
            showAlert = true
            return
        }
        
        Task {
            do {
                // Here we would call authorizeQr(id) from our Networking layer
                // For now, let's assume we have a helper
                try await authorizeWebSession(qrId: id)
                alertMessage = "Login Berhasil Direstui! Dashboard web Anda akan segera terbuka."
                showAlert = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    isPresented = false
                }
            } catch {
                alertMessage = "Gagal merestui login: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }
    
    private func authorizeWebSession(qrId: String) async throws {
        let body = QRAuthorizeRequest(qrId: qrId)
        let _: GenericResponse = try await APIClient.shared.request(
            endpoint: "auth/qr/authorize",
            method: .post,
            body: body
        )
        print("Successfully authorized QR Session: \(qrId)")
    }
}

// Minimalist Scanner Implementation using AVFoundation
struct CodeScannerView: UIViewControllerRepresentable {
    let codeTypes: [AVMetadataObject.ObjectType]
    let completion: (Result<String, Error>) -> Void

    func makeUIViewController(context: Context) -> ScannerViewController {
        let viewController = ScannerViewController()
        viewController.delegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }

    class Coordinator: NSObject, ScannerViewControllerDelegate {
        let completion: (Result<String, Error>) -> Void

        init(completion: @escaping (Result<String, Error>) -> Void) {
            self.completion = completion
        }

        func didFindCode(_ code: String) {
            completion(.success(code))
        }

        func didFailWithError(_ error: Error) {
            completion(.failure(error))
        }
    }
}

protocol ScannerViewControllerDelegate: AnyObject {
    func didFindCode(_ code: String)
    func didFailWithError(_ error: Error)
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    weak var delegate: ScannerViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            delegate?.didFailWithError(error)
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
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

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            delegate?.didFindCode(stringValue)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
}
