//
//  ViewController.swift
//  testApp
//
//  Created by 松尾大雅 on 2019/09/27.
//  Copyright © 2019 litech. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var nameInputView: UITextField!
    @IBOutlet weak var messageInputView: UITextField!
    @IBOutlet weak var inputViewBottomMargin: NSLayoutConstraint!

    //初期設定　Database.database().reference()でインスタンスを取得
    var databaseRef: DatabaseReference!

    //データの読み込み
    override func viewDidLoad() {
        super.viewDidLoad()

        databaseRef = Database.database().reference()

        databaseRef.observe(.childAdded, with: { snapshot in //observeでイベントの監視.childAddedを指定して、子要素が追加されたときにwithで与えた処理が実行
            dump(snapshot)
            if let obj = snapshot.value as? [String : AnyObject], let name = obj["name"] as? String, let message = obj["message"] {
                let currentText = self.textView.text
                self.textView.text = (currentText ?? "") + "\n\(name) : \(message)"
            }
        })
//入力域がキーボードで隠れないように動的に入力域の位置を変更
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)

    }
//ボタンを押した時に、UITextField２つに入力されている値を送信
    @IBAction func tappedSendButton(_ sender: Any) {
        view.endEditing(true)

        if let name = nameInputView.text, let message = messageInputView.text {
            let messageData = ["name": name, "message": message]
            databaseRef.childByAutoId().setValue(messageData)

            messageInputView.text = ""
        }
    }

    @objc func keyboardWillShow(_ notification: NSNotification){
        if let userInfo = notification.userInfo, let keyboardFrameInfo = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            inputViewBottomMargin.constant = keyboardFrameInfo.cgRectValue.height
        }

    }

    @objc func keyboardWillHide(_ notification: NSNotification){
        inputViewBottomMargin.constant = 0
    }

}
