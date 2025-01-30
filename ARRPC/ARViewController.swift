import UIKit
import ARKit
import RealityKit
import Vision

class ARViewController: UIViewController, ARSessionDelegate {
    
    private var arView: ARView!
    private var gestureRecognizer: GestureRecognizer!
    private var gameLogic: GameLogic!
    private var resultLabel: UILabel!
    private var countdownLabel: UILabel!
    private var startButton: UIButton!
    private var lastProcessedTime: TimeInterval = 0
    private var processingInterval: TimeInterval = 0.5
    private var gameTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAR()
        setupUI()
        gestureRecognizer = GestureRecognizer()
        gameLogic = GameLogic()
    }
    
    private func setupAR() {
        arView = ARView(frame: view.bounds)
        view.addSubview(arView)
        arView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        arView.session.delegate = self
        
        guard ARWorldTrackingConfiguration.isSupported else {
            showARNotSupportedAlert()
            return
        }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        configuration.frameSemantics = [.personSegmentation]
        arView.session.run(configuration)
    }
    
    private func setupUI() {
        countdownLabel = UILabel(frame: CGRect(x: 0, y: view.bounds.height/3, width: view.bounds.width, height: 100))
        countdownLabel.textAlignment = .center
        countdownLabel.textColor = .white
        countdownLabel.font = .systemFont(ofSize: 72, weight: .bold)
        countdownLabel.isHidden = true
        view.addSubview(countdownLabel)
        
        resultLabel = UILabel(frame: CGRect(x: 0, y: 50, width: view.bounds.width, height: 100))
        resultLabel.textAlignment = .center
        resultLabel.textColor = .white
        resultLabel.font = .systemFont(ofSize: 24, weight: .bold)
        resultLabel.numberOfLines = 0
        view.addSubview(resultLabel)
        
        startButton = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
        startButton.setTitle("Start Game", for: .normal)
        startButton.backgroundColor = .systemBlue
        startButton.layer.cornerRadius = 25
        startButton.center = CGPoint(x: view.center.x, y: view.bounds.height - 100)
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        view.addSubview(startButton)
    }
    
    @objc private func startButtonTapped() {
        startButton.isEnabled = false
        gameLogic.startNewGame()
        startCountdown()
    }
    
    private func startCountdown() {
        countdownLabel.isHidden = false
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            self.countdownLabel.text = "\(self.gameLogic.countdown)"
            
            if self.gameLogic.countdown > 1 {
                self.gameLogic.countdown -= 1
            } else if self.gameLogic.countdown == 1 {
                self.countdownLabel.text = "GO!"
                self.gameLogic.countdown -= 1
                self.gameLogic.gameState = .playing
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.countdownLabel.isHidden = true
                    self.startGameDuration()
                }
            }
        }
    }
    
    private func startGameDuration() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.gameLogic.playGame()
            self.updateGameResult()
            self.startButton.isEnabled = true
        }
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let currentTime = CACurrentMediaTime()
        guard currentTime - lastProcessedTime >= processingInterval else { return }
        lastProcessedTime = currentTime
        
        guard gameLogic.gameState == .playing else { return }
        
        let pixelBuffer = frame.capturedImage
        gestureRecognizer.recognizeGesture(from: pixelBuffer) { [weak self] gesture in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let gesture = gesture {
                    self.gameLogic.updateUserGesture(gesture)
                    self.updateCurrentGesture()
                }
            }
        }
    }
    
    private func updateCurrentGesture() {
        if gameLogic.gameState == .playing {
            resultLabel.text = "Current Gesture: \(gameLogic.userGesture)"
        }
    }
    
    private func updateGameResult() {
        let resultText = """
        You: \(gameLogic.userGesture)
        Computer: \(gameLogic.computerGesture)
        Result: \(gameLogic.result)
        """
        resultLabel.text = resultText
    }
    
    // MARK: - AR Session Delegate Methods
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Handle session failures
        guard let arError = error as? ARError else { return }
        
        let errorMessage: String
        switch arError.errorCode {
//        case .cameraUnauthorized:
//            errorMessage = "Camera access is not authorized"
//        case .worldTrackingFailed:
//            errorMessage = "World tracking failed. Try moving to an area with better lighting and more visual features."
        default:
            errorMessage = "An AR session error occurred: \(error.localizedDescription)"
        }
        
        showAlert(title: "AR Session Error", message: errorMessage)
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        showAlert(title: "Session Interrupted", 
                 message: "AR session was interrupted. Please wait for automatic restart.")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        resetARSession()
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .normal:
            // Tracking is normal
            break
        case .limited(let reason):
            handleLimitedTracking(reason)
        case .notAvailable:
            showAlert(title: "Tracking Not Available", 
                     message: "AR tracking is currently not available.")
        @unknown default:
            break
        }
    }
    
    // MARK: - Helper Methods
    
    private func resetARSession() {
        guard let configuration = arView.session.configuration else { return }
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    private func handleLimitedTracking(_ reason: ARCamera.TrackingState.Reason) {
        let message: String
        switch reason {
        case .initializing:
            message = "AR session is initializing"
        case .excessiveMotion:
            message = "Too much motion - slow down"
        case .insufficientFeatures:
            message = "Not enough surface detail - try a different area"
        case .relocalizing:
            message = "Relocalizing AR session"
        @unknown default:
            message = "AR tracking is limited"
        }
        
        showAlert(title: "Limited Tracking", message: message)
    }
    
    private func showARNotSupportedAlert() {
        showAlert(title: "AR Not Supported", message: "This device does not support AR functionality.")
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
} 
