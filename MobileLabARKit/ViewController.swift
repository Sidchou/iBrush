//  ViewController.swift
//  based on MobileLabARKit
//  https://github.com/mobilelabclass/mobile-lab-ar-kit
//  Created by Nien Lam on 3/21/18.
//  Copyright © 2018 Mobile Lab. All rights reserved.

import UIKit
import SceneKit
import ARKit

// Models from model_asset_scene.scn
let ModelAssets: [(name: String, nodeName: String)] = [
    ("Box", "box"),
   ("Plan Brush",  "planeBrush"),
   ("Brush",  "Brush"),
   ("Sphere", "sphere")]


class ViewController: UIViewController {

    // Outlet for arkit scene.
    @IBOutlet var sceneView: ARSCNView!

    // Outlets for menu UI menu items.
    @IBOutlet weak var modelAssetButtonView: UIView!
//    @IBOutlet weak var placementModeButtonView: UIView!
    @IBOutlet weak var photoSnapshotButtonView: UIView!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var undoButtonView: UIView!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var paintButtonView: UIView!
    @IBOutlet weak var paintButton2View: UIButton!
    @IBOutlet weak var paintButton: UIButton!
    @IBOutlet weak var paintButton2: UIButton!
    
    // References to scenes.
    var mainScene: SCNScene!
    var modelAssetScene: SCNScene!
    
    // Structure for cycling through model assets.
    var modelAssets = CycleArray(ModelAssets)

    // Currently selected model to place in scene.
    var currentModelAsset: SCNNode!

    // Toggle to hide menu.
    var isMenuHidden = false

    // Toggle between space placement and plane placement.
    var isSpacePlacement = true

    // Array for tracking models added to scene.
    var modelsInScene = [SCNNode]()

    // Array for ar anchor planes added to scene.
    var anchorPlanesInScene = [SCNNode]()
    var timer: Timer!
    var startPaint = false


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false


        // Main scene of project.
        mainScene = SCNScene(named: "art.scnassets/main_scene.scn")!

        // Set the scene to the view
        sceneView.scene = mainScene


        // Scene for model assets.
        modelAssetScene = SCNScene(named: "art.scnassets/model_asset_scene.scn")!
        
        // Set current selected model.
        currentModelAsset = modelAssetScene.rootNode.childNode(withName: modelAssets.currentElement!.nodeName, recursively: true)

        
//         Setup tap gesture for screen.
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
//        sceneView.addGestureRecognizer(tapGesture)
//        let holdGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongTap))
//        sceneView.addGestureRecognizer(holdGesture)

        
//        photoSnapshotButtonView.frame.size.width = sceneView.bounds.width * 0.15
//        photoSnapshotButtonView.clipsToBounds = true
//        photoSnapshotButtonView.layer.cornerRadius = photoSnapshotButtonView.bounds.width/2
//        photoButton.frame.size.width = photoSnapshotButtonView.bounds.width * 0.9
//        photoButton.setImage(UIImage(named: "camera_icon.png"), for: .normal)
//        photoButton.imageView?.contentMode = .scaleAspectFill
//        photoButton.tintColor = .black
//        undoButton.frame.size.width = undoButtonView.bounds.width * 0.75
//        undoButton.imageView?.contentMode = .scaleAspectFill
//        undoButton.setImage(UIImage(named: "back_icon.png"), for: .normal)
//        undoButton.tintColor = .black

        
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Check if ARKit is supported on device.
        guard ARWorldTrackingConfiguration.isSupported else {
            fatalError("""
                ARKit is not available on this device. For apps that require ARKit
                for core functionality, use the `arkit` key in the key in the
                `UIRequiredDeviceCapabilities` section of the Info.plist to prevent
                the app from installing. (If the app can't be installed, this error
                can't be triggered in a production scenario.)
                In apps where AR is an additive feature, use `isSupported` to
                determine whether to show UI for launching AR experiences.
            """) // For details, see https://developer.apple.com/documentation/arkit
        }

        // Start the view's AR session with a configuration that uses the rear camera,
        // device position and orientation tracking, and plane detection.
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        sceneView.session.run(configuration)
        
        // Set a delegate to track the number of plane anchors for providing UI feedback.
        sceneView.session.delegate = self
        
        // Prevent the screen from being dimmed after a while as users will likely
        // have long periods of interaction without touching the screen or buttons.
        UIApplication.shared.isIdleTimerDisabled = true
        
        //configuring buttons
        photoSnapshotButtonView.frame.size.width = sceneView.bounds.width * 0.15
        photoSnapshotButtonView.clipsToBounds = true
        photoSnapshotButtonView.layer.cornerRadius = photoSnapshotButtonView.bounds.width/2
        photoButton.frame.size.width = photoSnapshotButtonView.bounds.width * 0.8
        photoButton.imageView?.contentMode = .scaleAspectFill
        photoButton.setImage(UIImage(named: "camera_icon.png"), for: .normal)
        photoButton.tintColor = .black
        undoButton.frame.size.width = undoButtonView.bounds.width * 0.5
        undoButton.setImage(UIImage(named: "hide_icon.png"), for: .normal)
        undoButton.imageView?.contentMode = .scaleAspectFill
        undoButton.tintColor = .black
        
        paintButtonView.clipsToBounds = true
        paintButtonView.layer.cornerRadius = 25
        paintButton.backgroundColor = .red
        paintButton.clipsToBounds = true
        paintButton.layer.cornerRadius = 22
        paintButton2View.clipsToBounds = true
        paintButton2View.layer.cornerRadius = 25
        paintButton2.backgroundColor = .blue
        paintButton2.clipsToBounds = true
        paintButton2.layer.cornerRadius = 22
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    @IBAction func touchDown(_ sender: Any) {
//       print("down")
        startPaint = true
     keepPaint()

    }
    
    @IBAction func touchUp(_ sender: Any) {
//        print("up")
        startPaint = false


    }
    
    

    //    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
//        startPaint = true
//
//        if startPaint{
////        paint()
////            print("tap")
//
//        }
//
//        if recognizer.state == .ended {
//            startPaint = false
//            print("end tap")
//        }
//    }
//    @objc func handleLongTap(_ recognizer: UITapGestureRecognizer) {
//
//        startPaint = true
//        if startPaint{
////            paint()
//
//      print("holding")
//    }
//        if recognizer.state == .ended {
//            startPaint = false
//            print("end holding")
//        }
////        keepPaint()
////        paint(UITapGestureRecognizer.location)
////
//    }
    
    func keepPaint(){
//        print("start paint")
        if startPaint { DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.paint()
            self.keepPaint()
        }}
        
    }



    func paint() {
//        print("paint")

        // Get tapped location in scene.
//        let location = recognizer.location(in: sceneView)
//        print(location)
    ///////////////////////////////////////////////////////////////////////
        // Handle object tap.
//        let sceneHitTestResult = sceneView.hitTest(location, options: nil)
//        if !sceneHitTestResult.isEmpty {
//            let hit = sceneHitTestResult.first!
//        
//            print("Tapping: \(hit.node.name!)")
//        }

// Don't place any objects menu is hidden.
        if isMenuHidden {
            return
        }

        // Get point of view
        guard let pov = sceneView.pointOfView else {
            return
        }
        
        // Space Placement: Places current selected model in 3d space.
        
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.1
            
            let modelAsset = currentModelAsset.clone() as SCNNode

            // Position and rotate relative to camera point of view.
            modelAsset.simdPosition = pov.simdPosition + pov.simdWorldFront * 0.1
            modelAsset.simdRotation = pov.simdRotation
            
            modelAsset.name = modelAssets.currentElement!.name

            sceneView.scene.rootNode.addChildNode(modelAsset);
            
            modelsInScene.append(modelAsset)
        
    }
    
    // Button to cycle to next model to set as current.
    @IBAction func handleModelAssetButton(_ sender: UIButton) {
        let modelAsset = modelAssets.cycle()!
        currentModelAsset = modelAssetScene.rootNode.childNode(withName: modelAsset.nodeName, recursively: true)
        sender.setTitle(modelAsset.name, for: .normal)

//        let placementLabel = isSpacePlacement ? "Space" : "Plane"
    }

    
    @IBAction func handlePhotoSnapshot(_ sender: UIButton) {
        // Get point of view
        guard let pov = sceneView.pointOfView else {
            return
        }

        // Create image plane from sceneView snapshot and camera position.
        let imagePlane = SCNPlane(width: sceneView.bounds.width / 6000,
                                  height: sceneView.bounds.height / 6000)
        
        imagePlane.firstMaterial?.diffuse.contents = sceneView.snapshot()
        imagePlane.firstMaterial?.lightingModel = .constant
        
        let planeNode = SCNNode(geometry: imagePlane)
        sceneView.scene.rootNode.addChildNode(planeNode)

        // Position and rotate relative to camera point of view.
        planeNode.simdPosition = pov.simdPosition + pov.simdWorldFront * 0.1
        planeNode.simdRotation = pov.simdRotation
        
        modelsInScene.append(planeNode)
    }
    
    // Undo button, removes last added node.
    @IBAction func handleUndoButton(_ sender: UIButton) {
        if let lastModel = modelsInScene.popLast() {
            lastModel.removeFromParentNode()
        }
    }
    
    // Menu toggle button.
    @IBAction func handleToggleMenuButton(_ sender: UIButton) {
        isMenuHidden = !isMenuHidden

        let image = isMenuHidden ? "show" : "hide"
        undoButton.setImage(UIImage(named: "\(image)_icon.png"), for: .normal)
        undoButton.tintColor = .black
        
        modelAssetButtonView.isHidden     = isMenuHidden
        undoButtonView.isHidden           = isMenuHidden
        photoSnapshotButtonView.isHidden  = isMenuHidden
    
        // Hide/Show are ar anchor planes.
        for anchorPlane in anchorPlanesInScene {
            anchorPlane.isHidden = isMenuHidden
        }
    }

}

extension ViewController: ARSCNViewDelegate, ARSessionDelegate {
    // MARK: - ARSCNViewDelegate
    
    /// - Tag: PlaceARContent
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Place content only for anchors found by plane detection.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // Create a SceneKit plane to visualize the plane anchor using its position and extent.
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode(geometry: plane)
        planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        /*
         `SCNPlane` is vertically oriented in its local coordinate space, so
         rotate the plane to match the horizontal orientation of `ARPlaneAnchor`.
         */
        planeNode.eulerAngles.x = -.pi / 2
        
        // Make the plane visualization semitransparent to clearly show real-world placement.
        planeNode.opacity = 0.25
        
        planeNode.name = "anchor"
        
        /*
         Add the plane visualization to the ARKit-managed node so that it tracks
         changes in the plane anchor as plane estimation continues.
         */
        node.addChildNode(planeNode)

        // Save all plane nodes.
        anchorPlanesInScene.append(planeNode)
    }
    
    /// - Tag: UpdateARContent
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Update content only for plane anchors and nodes matching the setup created in `renderer(_:didAdd:for:)`.
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        // Plane estimation may shift the center of a plane relative to its anchor's transform.
        planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        /*
         Plane estimation may extend the size of the plane, or combine previously detected
         planes into a larger one. In the latter case, `ARSCNView` automatically deletes the
         corresponding node for one plane, then calls this method to update the size of
         the remaining plane.
         */
        plane.width = CGFloat(planeAnchor.extent.x)
        plane.height = CGFloat(planeAnchor.extent.z)
    }
    
    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }
    
    // MARK: - ARSessionObserver
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay.
//        sessionInfoLabel.text = "Session was interrupted"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required.
//        sessionInfoLabel.text = "Session interruption ended"
        resetTracking()
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user.
//        sessionInfoLabel.text = "Session failed: \(error.localizedDescription)"
        resetTracking()
    }
    
    // MARK: - Private methods
    
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        let message: String
        
        switch trackingState {
        case .normal where frame.anchors.isEmpty:
            // No planes detected; provide instructions for this app's AR interactions.
            message = "Move the device around to detect horizontal surfaces."
            
        case .normal:
            // No feedback needed when tracking is normal and planes are visible.
            message = ""
            
        case .notAvailable:
            message = "Tracking unavailable."
            
        case .limited(.excessiveMotion):
            message = "Tracking limited - Move the device more slowly."
            
        case .limited(.insufficientFeatures):
            message = "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
            
        case .limited(.initializing):
            message = "Initializing AR session."
            
        case .limited(.relocalizing):
            message = "Relocalizing."
        }
        
//        sessionInfoLabel.text = message
//        sessionInfoView.isHidden = message.isEmpty
    }
    
    private func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}



