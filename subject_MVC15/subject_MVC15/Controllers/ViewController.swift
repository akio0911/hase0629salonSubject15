//
//  ViewController.swift
//  subject_MVC15
//
//  Created by 長谷川孝太 on 2021/07/02.
//

import UIKit

final class ViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!

    private var fruitsArray: [Fruit] = []
    private static let initialFruitsArray = [
        Fruit(isChecked: false, name: "りんご"),
        Fruit(isChecked: true, name: "みかん"),
        Fruit(isChecked: false, name: "バナナ"),
        Fruit(isChecked: true, name: "パイナップル")
    ]
    private let fruitsArrayRepository = FruitsArrayRepository()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(FruitTableViewCell.nib(), forCellReuseIdentifier: FruitTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        fruitsArray = self.fruitsArrayRepository.load() ?? Self.initialFruitsArray
    }

    @IBAction private func addCellDidTapped(_ sender: UIBarButtonItem) {
        let inputFruitViewController = InputFruitViewController.instantiate(
            didSaveFruits: { [weak self] text in
                // 【メモ】guard let 文でself?を書かないで済むようにアンラップ
                guard let strongSelf = self else { return }
                let newFruit = Fruit(isChecked: false, name: text)
                strongSelf.fruitsArray.append(newFruit)
                _ = strongSelf.fruitsArrayRepository.save(newFruitsArray: strongSelf.fruitsArray)
                // 【疑問】ここでreloadDataを呼ぶ必要はあるのか？
                //                strongSelf.tableView.reloadData()
                strongSelf.dismiss(animated: true, completion: nil)
            },
            didCancel: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }
        )
        let navigationController = UINavigationController(
            rootViewController: inputFruitViewController
        )
        present(navigationController, animated: true)
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 【疑問】ここでtoggleするのは、UIViewControllerとUITableViewCellのどちらにやらせるべき？
        // 【解決策】TableViewCell内にもModelとして共有する配列を作り、toggleする専用のメソッドを作る
        fruitsArray[indexPath.row].isChecked.toggle()
        _ = self.fruitsArrayRepository.save(newFruitsArray: self.fruitsArray)
        // 【疑問】ここでreloadDataを呼ぶ必要はあるのか？
        //        self.tableView.reloadData()
        let cell = tableView.cellForRow(at: indexPath) as! FruitTableViewCell
        cell.configure(fruit: fruitsArray[indexPath.row])
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fruitsArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let customCell = tableView.dequeueReusableCell(
            withIdentifier: FruitTableViewCell.identifier, for: indexPath) as! FruitTableViewCell
        customCell.configure(fruit: fruitsArray[indexPath.row])
        return customCell
    }
}
