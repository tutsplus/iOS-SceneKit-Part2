//
//  ViewController.swift
//  SceneKit Tutorial 2
//
//  Created by Davis Allie on 24/04/2015.
//  Copyright (c) 2015 Tutsplus. All rights reserved.
//

import UIKit
import SceneKit

class ViewController: UIViewController, SCNPhysicsContactDelegate {
    
    var sceneView: SCNView!
    var camera: SCNNode!
    var ground: SCNNode!
    var light: SCNNode!
    var button: SCNNode!
    var sphere1: SCNNode!
    var sphere2: SCNNode!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        sceneView = SCNView(frame: self.view.frame)
        sceneView.scene = SCNScene()
        sceneView.scene?.physicsWorld.contactDelegate = self
        self.view.addSubview(sceneView)
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        tapRecognizer.addTarget(self, action: "sceneTapped:")
        sceneView.gestureRecognizers = [tapRecognizer]
        
        let groundGeometry = SCNFloor()
        groundGeometry.reflectivity = 0
        let groundMaterial = SCNMaterial()
        groundMaterial.diffuse.contents = UIColor.blueColor()
        groundGeometry.materials = [groundMaterial]
        ground = SCNNode(geometry: groundGeometry)
        
        let camera = SCNCamera()
        camera.zFar = 10000
        self.camera = SCNNode()
        self.camera.camera = camera
        self.camera.position = SCNVector3(x: -20, y: 15, z: 20)
        let constraint = SCNLookAtConstraint(target: ground)
        constraint.gimbalLockEnabled = true
        self.camera.constraints = [constraint]
        
        let ambientLight = SCNLight()
        ambientLight.color = UIColor.darkGrayColor()
        ambientLight.type = SCNLightTypeAmbient
        self.camera.light = ambientLight
        
        let spotLight = SCNLight()
        spotLight.type = SCNLightTypeSpot
        spotLight.castsShadow = true
        spotLight.spotInnerAngle = 70.0
        spotLight.spotOuterAngle = 90.0
        spotLight.zFar = 500
        light = SCNNode()
        light.light = spotLight
        light.position = SCNVector3(x: 0, y: 25, z: 25)
        light.constraints = [constraint]
        
        let sphereGeometry = SCNSphere(radius: 1.5)
        let sphereMaterial = SCNMaterial()
        sphereMaterial.diffuse.contents = UIColor.greenColor()
        sphereGeometry.materials = [sphereMaterial]
        sphere1 = SCNNode(geometry: sphereGeometry)
        sphere1.position = SCNVector3(x: -15, y: 1.5, z: 0)
        sphere2 = SCNNode(geometry: sphereGeometry)
        sphere2.position = SCNVector3(x: 15, y: 1.5, z: 0)
        
        let buttonGeometry = SCNBox(width: 4, height: 1, length: 4, chamferRadius: 0)
        let buttonMaterial = SCNMaterial()
        buttonMaterial.diffuse.contents = UIColor.redColor()
        buttonGeometry.materials = [buttonMaterial]
        button = SCNNode(geometry: buttonGeometry)
        button.position = SCNVector3(x: 0, y: 0.5, z: 15)
        
        // Physics
        let groundShape = SCNPhysicsShape(geometry: groundGeometry, options: nil)
        let groundBody = SCNPhysicsBody(type: .Kinematic, shape: groundShape)
        ground.physicsBody = groundBody
        
        let gravityField = SCNPhysicsField.radialGravityField()
        gravityField.strength = 0
        sphere1.physicsField = gravityField
        
        let shape = SCNPhysicsShape(geometry: sphereGeometry, options: nil)
        let sphere1Body = SCNPhysicsBody(type: .Kinematic, shape: shape)
        sphere1.physicsBody = sphere1Body
        let sphere2Body = SCNPhysicsBody(type: .Dynamic, shape: shape)
        sphere2.physicsBody = sphere2Body
        
        sceneView.scene?.rootNode.addChildNode(self.camera)
        sceneView.scene?.rootNode.addChildNode(ground)
        sceneView.scene?.rootNode.addChildNode(light)
        sceneView.scene?.rootNode.addChildNode(button)
        sceneView.scene?.rootNode.addChildNode(sphere1)
        sceneView.scene?.rootNode.addChildNode(sphere2)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sceneTapped(recognizer: UITapGestureRecognizer) {
        let location = recognizer.locationInView(sceneView)
        
        let hitResults = sceneView.hitTest(location, options: nil)
        if hitResults?.count > 0 {
            let result = hitResults![0] as! SCNHitTestResult
            let node = result.node
            
            if node == button {
                SCNTransaction.begin()
                SCNTransaction.setAnimationDuration(0.5)
                let materials = node.geometry?.materials as! [SCNMaterial]
                let material = materials[0]
                material.diffuse.contents = UIColor.whiteColor()
                SCNTransaction.commit()
                
                let action = SCNAction.moveByX(0, y: -0.8, z: 0, duration: 0.5)
                node.runAction(action)
                
                sphere1.physicsField?.strength = 750
            }
        }
    }
    
    func physicsWorld(world: SCNPhysicsWorld, didUpdateContact contact: SCNPhysicsContact) {
        if (contact.nodeA == sphere1 || contact.nodeA == sphere2) && (contact.nodeB == sphere1 || contact.nodeB == sphere2) {
            let particleSystem = SCNParticleSystem(named: "Explosion", inDirectory: nil)
            let systemNode = SCNNode()
            systemNode.addParticleSystem(particleSystem)
            systemNode.position = contact.nodeA.position
            sceneView.scene?.rootNode.addChildNode(systemNode)
            
            contact.nodeA.removeFromParentNode()
            contact.nodeB.removeFromParentNode()
        }
    }
}