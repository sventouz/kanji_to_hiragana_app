//
//  ViewController.swift
//  KanjiToHiragana
//
//  Created by higuchiryunosuke on 2020/01/11.
//  Copyright © 2020 higuchiryunosuke. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var convertText: UITextField!
    @IBOutlet weak var convertedText: UILabel!
    @IBOutlet weak var errorText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func convertButton(_ sender: Any) {
        
        let convertTextForApi = convertText.text!
        
        if convertTextForApi == "" {
            errorText.text = "漢字を入力してください。"
            return
        } else {
            errorText.text = ""
        }
    
        // URLRequstの設定
        var request = URLRequest(url: URL(string: "https://labs.goo.ne.jp/api/hiragana")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //POSTするデータをURLRequestに持たせる
        let postData = PostData(app_id: "d6174bbccc90aef657551e3ac46ec5a99a2ebf3af2bcb0218d1f580f5e38ca8d", request_id: "record003", sentence: convertTextForApi, output_type: "hiragana")
        guard let uploadData = try? JSONEncoder().encode(postData) else {
            print("json生成に失敗しました")
            return
        }
        request.httpBody = uploadData
        //APIへPOSTしてresponseを受け取る
        let task = URLSession.shared.uploadTask(with: request, from: uploadData) {
            data, response, error in
            if let error = error {
                print ("error: \(error)")
                return
            }
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
                    print ("server error")
                    return
            }
            if response.statusCode == 200 {
                guard let data = data, let jsonData = try? JSONDecoder().decode(Rubi.self, from: data) else {
                    print("json変換に失敗しました")
                    return
                }
                print(jsonData.converted)
                DispatchQueue.main.async {
                    self.convertedText.text = jsonData.converted
                }
            } else {
                print("サーバエラー ステータスコード: \(response.statusCode)\n")
            }
        }
        task.resume()
    }
}




struct Rubi:Codable {
    var request_id: String
    var output_type: String
    var converted: String
}

struct PostData: Codable {
    var app_id:String
    var request_id: String
    var sentence: String
    var output_type: String
}
