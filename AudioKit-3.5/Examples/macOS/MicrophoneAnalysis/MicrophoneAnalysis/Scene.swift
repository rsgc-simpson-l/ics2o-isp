//
//  Scene.swift
//  MicrophoneAnalysis
//
//  Created by Russell Gordon on 12/14/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AudioKit
import SpriteKit

class Scene : SKScene {
    
    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var silence: AKBooster!
    var audioFile : AKAudioFile!
    var player : AKAudioPlayer!
    
    let noteFrequencies = [16.35,17.32,18.35,19.45,20.6,21.83,23.12,24.5,25.96,27.5,29.14,30.87]
    let noteNamesWithSharps = ["C", "C♯","D","D♯","E","F","F♯","G","G♯","A","A♯","B"]
    let noteNamesWithFlats = ["C", "D♭","D","E♭","E","F","G♭","G","A♭","A","B♭","B"]
    
    // Label for amplitude
    let labelAmplitude = SKLabelNode(fontNamed: "Helvetica")
    let labelFrequency = SKLabelNode(fontNamed: "Helvetica")
    let labelNoteSharps = SKLabelNode(fontNamed: "Helvetica")
    let labelNoteFlats = SKLabelNode(fontNamed: "Helvetica")
    
    // Circle
    var shapeCircle = SKShapeNode()
    var anotherCircle = SKShapeNode ()
    var shapeCirclePosition = CGPoint()
    var bar1 = SKShapeNode ()
    var bar2 = SKShapeNode ()
    var bar3 = SKShapeNode ()
    var bar4 = SKShapeNode ()

    
    // For tracking elapsed time
    var elapsedTime: Int = 0
    var startTime: Int?
    
    // For tracking frames
    var frameCount = 0
    
    override func didMove(to view: SKView) {
        
        // Set the background color
        backgroundColor = SKColor.black
        
        // Show the amplitude
        labelAmplitude.text = "Amplitude is: "
        labelAmplitude.fontColor = SKColor.white
        labelAmplitude.fontSize = 24
        labelAmplitude.zPosition = 150
        labelAmplitude.position = CGPoint(x: size.width / 2, y: size.height / 5 * 1)
        addChild(labelAmplitude)
        
        // Show the frequency
        labelFrequency.text = "Frequency is: "
        labelFrequency.fontColor = SKColor.white
        labelFrequency.fontSize = 24
        labelFrequency.zPosition = 150
        labelFrequency.position = CGPoint(x: size.width / 2, y: size.height / 5 * 2)
        addChild(labelFrequency)
        
        // Show the sharp notes
        labelNoteSharps.text = "Note (Sharps): "
        labelNoteSharps.fontColor = SKColor.white
        labelNoteSharps.fontSize = 24
        labelNoteSharps.zPosition = 150
        labelNoteSharps.position = CGPoint(x: size.width / 2, y: size.height / 5 * 3)
        addChild(labelNoteSharps)
        
        // Show the flat notes
        labelNoteFlats.text = "Note (Flats): "
        labelNoteFlats.fontColor = SKColor.white
        labelNoteFlats.fontSize = 24
        labelNoteFlats.zPosition = 150
        labelNoteFlats.position = CGPoint(x: size.width / 2, y: size.height / 5 * 4)
        addChild(labelNoteFlats)
        
        // Try to get a reference to the audio file
        do {
            audioFile = try AKAudioFile(readFileName: "Serenity.wav", baseDir: .resources)
        } catch {
            print("Could not open audio file")
        }
        
        // Play the audio file
        if audioFile != nil {
            
            do {
                player = try AKAudioPlayer(file: audioFile)
                player.looping = true
            } catch {
                print("Could not play audio file")
            }
            
        }
        
        // Analyse the song being played
        if player != nil {
            tracker = AKFrequencyTracker(player)
            
            // Start AudioKit
            AudioKit.output = tracker
            AudioKit.start()
            player.play()
        }
      
        // Configure the circle in the middle
        shapeCirclePosition = CGPoint(x: 25, y: 20)
   
        shapeCircle = SKShapeNode(circleOfRadius: 10)
        shapeCircle.position = shapeCirclePosition
        addChild(shapeCircle)
    
    }
    
    // This method runs approximately 30-60 times per second
    override func update(_ currentTime: TimeInterval) {
        
        // Check to see if visualization has been started yet
        if let startTime = startTime {
            // If started, how much time has elapsed?
            let time = Int(currentTime) - startTime
            if time != elapsedTime {
                elapsedTime = time
                print(elapsedTime)
            }
        } else {
            // If not started, set the start time
            startTime = Int(currentTime) - elapsedTime
        }
        
        // Increment frame count
        frameCount += 1
        
        // Remove the circles
        shapeCircle.removeFromParent()
        anotherCircle.removeFromParent()
        bar1.removeFromParent()
        bar2.removeFromParent()
        bar3.removeFromParent()
        bar4.removeFromParent()
        
        // Only analyze if volume (amplitude) reaches a certain threshold
        if tracker.amplitude > 0.1 && player != nil {
            
            // Show the frequency
            labelFrequency.text = "Frequency is: " + String(format: "%0.1f", tracker.frequency)
            
            // Not sure what this does, to be honest, it's from the AudioKit example file
            // I think it's to do with figuring out what note is playing
            var frequency = Float(tracker.frequency)
            while (frequency > Float(noteFrequencies[noteFrequencies.count-1])) {
                frequency = frequency / 2.0
            }
            while (frequency < Float(noteFrequencies[0])) {
                frequency = frequency * 2.0
            }
            
            // Not sure what this does either!
            // Need to ask Mr. Martin, who may understand the music theory better
            var minDistance: Float = 10000.0
            var index = 0
            
            for i in 0..<noteFrequencies.count {
                let distance = fabsf(Float(noteFrequencies[i]) - frequency)
                if (distance < minDistance){
                    index = i
                    minDistance = distance
                }
            }
            
            // Show the notes
            let octave = Int(log2f(Float(tracker.frequency) / frequency))
            labelNoteSharps.text = "Note (Sharps): " + "\(noteNamesWithSharps[index])\(octave)"
            labelNoteFlats.text = "Note (Flats): " + "\(noteNamesWithFlats[index])\(octave)"
            
            // Show the amplitude
            labelAmplitude.text = "Amplitude is: " + String(format: "%0.2f", tracker.amplitude)
            
            // Set the colour of the background based on the frequency
            // See for further details about how hue value works:
            // http://russellgordon.ca/rsgc/2016-17/ics2o/HSB%20Colour%20Model%20-%20Summary%20-%20Swift.pdf
  
            
        }
        
        // Resize the circle based on amplitude
        shapeCircle = SKShapeNode(circleOfRadius: CGFloat(tracker.amplitude * 100))
        shapeCircle.position = CGPoint(x: 440, y: 25)
        addChild(shapeCircle)

        // position of second circle
        anotherCircle = SKShapeNode(circleOfRadius: CGFloat(tracker.amplitude * 100))
        anotherCircle.position = CGPoint(x: 0, y: 25)
        addChild(anotherCircle)
        
        // Bar One Exploration
        let bar1Dimensions = CGRect(x:120, y: 0, width: 15, height: (tracker.amplitude * 150))
        bar1 = SKShapeNode(rect: bar1Dimensions)
        bar1.lineWidth = 20
        bar1.strokeColor = SKColor.orange
        addChild(bar1)
        
        // Bar Two Exploration
        let bar2Dimensions = CGRect(x:170, y: 0, width: 15, height: (tracker.frequency / 500))
        bar2 = SKShapeNode(rect: bar2Dimensions)
        bar2.lineWidth = 20
        bar2.strokeColor = SKColor.blue
        addChild(bar2)
        
        // Bar Three Exploration
        let bar3Dimensions = CGRect(x:270, y: 0, width: 15, height: (tracker.amplitude * 150))
        bar3 = SKShapeNode(rect: bar3Dimensions)
        bar3.lineWidth = 20
        bar3.strokeColor = SKColor.red
        addChild(bar3)
        
        // Bar Four Exploration
        let bar4Dimensions = CGRect(x:320, y: 0, width: 15, height: (tracker.amplitude * 150))
        bar4 = SKShapeNode(rect: bar4Dimensions)
        bar4.lineWidth = 20
        bar4.strokeColor = SKColor.green
        addChild(bar4)
        
        // Plot a line based on the frequency and the current frame
        if frameCount < Int(self.size.width) {  // Don't add nodes to the scene once we get past the right edge
            let shapeLine = SKShapeNode(rect: CGRect(x: frameCount, y: 0, width: 1, height: Int(tracker.amplitude * 500)))
            shapeLine.lineWidth = 1
            shapeLine.zPosition = 5
            shapeLine.strokeColor = NSColor(hue: 0, saturation: 0, brightness: 1.0, alpha: 0.2)
            addChild(shapeLine)
        }
        
    }
    
}
