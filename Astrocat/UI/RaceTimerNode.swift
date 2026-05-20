import SpriteKit

class RaceTimerNode: SKNode {
    private let minutesLabel = OutlinedLabelNode(fontSize: 56, strokeWidth: 3)
    private let colonLabel = OutlinedLabelNode(fontSize: 56, strokeWidth: 3)
    private let secondsLabel = OutlinedLabelNode(fontSize: 56, strokeWidth: 3)
    private let dotLabel = OutlinedLabelNode(fontSize: 56, strokeWidth: 3)
    private let hundredthsLabel = OutlinedLabelNode(fontSize: 56, strokeWidth: 3)
    
    private var lastDisplayedHundredths: Int = -1
    
    override init() {
        super.init()
        
        zPosition = 100
        position = CGPoint(x: 0, y: 540)
        isHidden = true
        
        minutesLabel.position = CGPoint(x: -88, y: 0)
        colonLabel.position = CGPoint(x: -50, y: 0)
        secondsLabel.position = CGPoint(x: 8, y: 0)
        dotLabel.position = CGPoint(x: 58, y: -10)
        hundredthsLabel.position = CGPoint(x: 108, y: 0)
        
        colonLabel.text = ":"
        dotLabel.text = "."
        
        addChild(minutesLabel)
        addChild(colonLabel)
        addChild(secondsLabel)
        addChild(dotLabel)
        addChild(hundredthsLabel)
        
        reset()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTime(_ time: TimeInterval) {
        let totalHundredths = Int(time * 100)
        
        guard totalHundredths != lastDisplayedHundredths else {
            return
        }
        
        lastDisplayedHundredths = totalHundredths
        
        let minutes = totalHundredths / 6000
        let seconds = (totalHundredths / 100) % 60
        let hundredths = totalHundredths % 100
        
        minutesLabel.text = "\(minutes)"
        secondsLabel.text = String(format: "%02d", seconds)
        hundredthsLabel.text = String(format: "%02d", hundredths)
    }
    
    func reset() {
        lastDisplayedHundredths = -1
        minutesLabel.text = "0"
        secondsLabel.text = "00"
        hundredthsLabel.text = "00"
        isHidden = false
    }
}
