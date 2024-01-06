//
// AudioSpectrum02
// A demo project for blog: https://juejin.im/post/5c1bbec66fb9a049cb18b64c
// Created by: potato04 on 2019/1/13
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var spectrumView: SpectrumView!
    @IBOutlet weak var trackTableView: UITableView!
    
    var player: AudioSpectrumPlayer!
    let record = AudioAnalyzer()
    private lazy var trackPaths: [String] = {
        var paths = Bundle.main.paths(forResourcesOfType: "mp3", inDirectory: nil)
        paths.sort()
        return paths.map { $0.components(separatedBy: "/").last! }
    }()
    
    private var currentPlayingRow: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        player = AudioSpectrumPlayer()
        player.delegate = self
        record.delegate = self;
    }
    override func viewDidLayoutSubviews() {
        let barSpace = spectrumView.frame.width / CGFloat(player.analyzer.frequencyBands * 3 - 1)
        spectrumView.barWidth = barSpace * 2
        spectrumView.space = barSpace
    }
}

// MARK: UITableViewDataSource
extension ViewController: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackPaths.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell") as! TrackCell
        cell.configure(trackName: "\(trackPaths[indexPath.row])", playing: currentPlayingRow == indexPath.row)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        let recordBtn = UIButton(type: .custom)
        recordBtn.setTitle("start", for: .normal)
        recordBtn.setTitle("end", for: .selected)
        headerView.addSubview(recordBtn)
        recordBtn.setTitleColor(.black, for: .normal)
        recordBtn.setTitleColor(.red, for: .selected)
        recordBtn.addTarget(self, action: #selector(startRecord(sender:)), for: .touchUpInside)
        headerView.frame = CGRectMake(0, 0, 200, 40)
        recordBtn.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
    @objc func startRecord(sender:UIButton){
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            debugPrint("开始录音")
            
            
            record.startAction()
        } else {
            record.stopAction()
            debugPrint("结束录音")
        }
    }
    
}

// MARK: TrackCellDelegate
extension ViewController: TrackCellDelegate {
    func playTapped(_ cell: TrackCell) {
        if let indexPath = trackTableView.indexPath(for: cell) {
            let previousPlayingRow = currentPlayingRow
            self.currentPlayingRow = indexPath.row
            if indexPath.row != previousPlayingRow && previousPlayingRow != nil  {
                trackTableView.reloadRows(at: [IndexPath(row: previousPlayingRow!, section: 0)], with: .none)
            }
            player.play(withFileName: trackPaths[indexPath.row])
        }
    }
    func stopTapped(_ cell: TrackCell) {
        self.currentPlayingRow = nil
        player.stop()
    }
}

// MARK: SpectrumPlayerDelegate
extension ViewController: AudioSpectrumPlayerDelegate {
    func player(_ player: AudioSpectrumPlayer, didGenerateSpectrum spectra: [[Float]]) {
        DispatchQueue.main.async {
            self.spectrumView.spectra = spectra
        }
    }
    func player(didGenerateSpectrum spectra: [[Float]]) {
        DispatchQueue.main.async {
            self.spectrumView.spectra = spectra
        }
    }
}
