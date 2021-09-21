//
//  ViewController.swift
//  practiceEffector
//
//  Created by 立岡力 on 2021/09/20.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    // 音声関連の材料をインスタンス化
    var audioRecorder: AVAudioRecorder!
    var audioEngine: AVAudioEngine!
    var audioFile: AVAudioFile!
    var audioPlayerNode: AVAudioPlayerNode!
    var audioUnitTimePitch: AVAudioUnitTimePitch!

    
    //MARK Outlet
    
    
    @IBOutlet weak var distortionOne: UISwitch!{
        didSet{
            distortionOne.isOn = false
        }
    }
    
    
    @IBOutlet weak var distortionTwo: UISwitch!{
        didSet{
            distortionTwo.isOn = false
        }
    }
    
    
    @IBOutlet weak var distortionThree: UISwitch!{
        didSet{
            distortionThree.isOn = false
        }
    }
    
    @IBOutlet weak var distortionFour: UISwitch!{
        didSet{
            distortionFour.isOn = false
        }
    }
    
    
    @IBOutlet weak var recordButton: UIButton!
    
    
    
    @IBOutlet weak var playButton: UIButton!{
        didSet{
            playButton.isEnabled = false
        }
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpAudioRecorder()
    }

    // 音声出力の初期設定
    func setUpAudioRecorder() {
        let session = AVAudioSession.sharedInstance()
        
        // 例外処理
        do {
            try session.setCategory(
                .playAndRecord,
                mode: .default,
                options: [.defaultToSpeaker,      // レシーバーからスピーカーへ移行
                          .allowAirPlay,          // AirPlayデバイスにストリーミングできる
                          .allowBluetoothA2DP])   // Bluetoothイヤホンでも録音再生ができる
            
            try session.setActive(true)
            
            // 音源情報の設定
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            // データフォルダから音源を取得する
            audioRecorder = try AVAudioRecorder(url: getAudioFileUrl(), settings: settings)
            audioRecorder.delegate = self as? AVAudioRecorderDelegate
            
        // エラー処理
        } catch let error {
            print(error)
        }
    }
    

    
    
    // サウンド設定
    
    func playSound(one: Bool, two: Bool, three: Bool, four: Bool) {
        
        audioEngine = AVAudioEngine()
        let url = getAudioFileUrl()
        
        
        do {
            audioFile = try AVAudioFile(forReading: url)
            
            // 再生ノードをエンジンに接続
            audioPlayerNode = AVAudioPlayerNode()
            audioEngine.attach(audioPlayerNode)
            
            
            // ノードを生成エンジンにアタッチ
            let oneNode = AVAudioUnitDistortion()
            oneNode.loadFactoryPreset(.speechGoldenPi)
            audioEngine.attach(oneNode)
            
            // ノードを生成エンジンにアタッチ
            let twoNode = AVAudioUnitDistortion()
            twoNode.loadFactoryPreset(.speechWaves)
            audioEngine.attach(twoNode)
            
            // 条件分岐
            if one && two {
                connectAudioNodes(audioPlayerNode, oneNode, twoNode, audioEngine.outputNode)
            } else if one {
                connectAudioNodes(audioPlayerNode, oneNode, audioEngine.outputNode)
            } else if two {
                connectAudioNodes(audioPlayerNode, twoNode, audioEngine.outputNode)
            } else {
                connectAudioNodes(audioPlayerNode, audioEngine.outputNode)
            }
            
            
            audioPlayerNode.stop()
            audioPlayerNode.scheduleFile(audioFile, at: nil)
            
            try audioEngine.start()
            audioPlayerNode.play()
            
        } catch let error {
            print(error)
        }
    }

    
    private func connectAudioNodes(_ nodes: AVAudioNode...) {
        for x in 0..<nodes.count - 1 {
            audioEngine.connect(nodes[x], to: nodes[x+1], format: audioFile.processingFormat)
        }
    }
    
    // アプリ内のデータフォルダを参照する
    private func getAudioFileUrl() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDirect = paths[0]
        let audioUrl = docsDirect.appendingPathComponent("recording.m4a")
        return audioUrl
    }
    
    // MARK Action
    
    
    @IBAction func record(_ sender: Any) {
        if !audioRecorder.isRecording {
            audioRecorder.record()
        } else {
            audioRecorder.stop()
            playButton.isEnabled = true
        }
    }
    
    
    
    @IBAction func play(_ sender: Any) {
        playSound(one: distortionOne.isOn,
                  two: distortionTwo.isOn,
                  three: distortionThree.isOn,
                  four: distortionFour.isOn)
    }
    
    
    
}








