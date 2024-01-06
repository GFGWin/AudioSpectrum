//
// AudioSpectrum02
// A demo project for blog: https://juejin.im/post/5c1bbec66fb9a049cb18b64c
// Created by: potato04 on 2024/1/4
//


import AVFoundation
import Accelerate

class AudioAnalyzer: NSObject, ObservableObject, AVAudioRecorderDelegate {
    
    public var analyzer: RealtimeAnalyzer!
    weak var delegate: AudioSpectrumPlayerDelegate?
    override init() {
        super.init()
        analyzer = RealtimeAnalyzer(fftSize: 2048)
        setupEngine()
    }
    // MARK: Variable
    /// 录音引擎
    private var audioEngine: AVAudioEngine = AVAudioEngine()
    /// 采样率
    private let sampleRate:Double = 48000
    /// 采样间隔
    private let ioBufferDuration = 0.1
    /// 位宽
    private let bit = 16
    /// 重采样队列
    private let audioQueue = DispatchQueue.init(label: "com.resample.test")
    
    

    // MARK: Action
    func startAction() {
        try? audioEngine.start()
    }
    func stopAction() {
        self.audioEngine.stop()
        self.audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    // MARK: Method
    private func setupEngine(){
        let audiosession = AVAudioSession.sharedInstance()
        do{
            try audiosession.setPreferredSampleRate(sampleRate)
            try audiosession.setPreferredIOBufferDuration(ioBufferDuration)
            try audiosession.setActive(true, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
        }catch{
            print(error)
        }
        let inputNode = audioEngine.inputNode
        inputNode.installTap(onBus: 0, bufferSize: AVAudioFrameCount(2048), format: nil) { (buffer, time) in
            buffer.frameLength = AVAudioFrameCount(2048)
            let spectra = self.analyzer.analyse(with: buffer)
            
            self.delegate!.player(didGenerateSpectrum: spectra)
        }
    }
    
    

}
