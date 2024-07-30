//
//  EditMeetingViewController.swift
//  Foodle
//
//  Created by 민정 on 7/19/24.
//

import UIKit

class EditMeetingViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var selectedName: UICollectionView!
    @IBOutlet var favLabel: UILabel!
    @IBOutlet var favTable: UITableView!
    @IBOutlet var allLabel: UILabel!
    @IBOutlet var allTable: UITableView!
    var section: Int?
    var index: Int?
    var collectionViewItem: Int?
    
    var Friends: [Friend] = friends!
    var todayMeetings: [Meeting] = meetingsToday
    var upcomingMeetings: [Meeting] = meetingsUpcoming
    
    // 모든 친구 데이터 (즐겨찾기 포함)
    var allFriends: [Friend] {
        return Friends
    }
    
    // 즐겨찾기한 친구 데이터
    var favFriends: [Friend] {
        return Friends.filter { $0.like }
    }
    
    var scrollView: UIScrollView!
    
    var meeting = dummyMeeting

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScrollView()
        
        self.title = "친구 선택"
        let nextButton = UIBarButtonItem(title: "다음", style: .plain, target: self, action: #selector(nextButtonTapped))
        navigationItem.rightBarButtonItem = nextButton
        
        selectedName.dataSource = self
        selectedName.delegate = self
        self.favTable.delegate = self
        self.favTable.dataSource = self
        self.allTable.delegate = self
        self.allTable.dataSource = self
        
        // favTable과 allTable의 스크롤 비활성화
        self.favTable.isScrollEnabled = false
        self.allTable.isScrollEnabled = false
    }
    
    @objc func nextButtonTapped() {
        performSegue(withIdentifier: "showSetMeeting", sender: self)
    }
    
    func setupScrollView() {
        scrollView = UIScrollView(frame: view.bounds)
        view.addSubview(scrollView)
        
        scrollView.addSubview(searchBar)
        scrollView.addSubview(selectedName)
        scrollView.addSubview(favLabel)
        scrollView.addSubview(favTable)
        scrollView.addSubview(allLabel)
        scrollView.addSubview(allTable)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        selectedName.frame.origin.y = searchBar.frame.maxY + 10
        favLabel.frame.origin.y = selectedName.frame.maxY + 10
        favTable.frame.origin.y = favLabel.frame.maxY + 10
        favTable.frame.size.height = CGFloat(favFriends.count) * 75 // favTable의 높이를 개수에 맞게 설정
        
        allLabel.frame.origin.y = favTable.frame.maxY + 30
        allTable.frame.origin.y = allLabel.frame.maxY + 10
        allTable.frame.size.height = CGFloat(allFriends.count) * 75 // allTable의 높이를 개수에 맞게 설정
        
        // 스크롤 뷰의 contentSize 조정
        let contentHeight = allTable.frame.origin.y + allTable.frame.size.height + 30
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: contentHeight)
    }
    
    func updateFriendState(for friend: Friend) {
        if isSelected(friend) {
            removeFriend(friend)
        } else {
            addFriend(friend)
        }
        
        selectedName.reloadData()
        favTable.reloadData()
        allTable.reloadData()
    }
    
    func addFriend(_ friend: Friend) {
        if let index = index {
            if self.section == 0 {
                todayMeetings[index].joiners?.append(friend.user)
            } else if self.section == 1 {
                upcomingMeetings[collectionViewItem!].joiners?.append(friend.user)
            }
        }
    }

    func removeFriend(_ friend: Friend) {
        if let index = index {
            if self.section == 0 {
                todayMeetings[index].joiners?.removeAll { $0.uid == friend.user.uid }
            } else if self.section == 1 {
                upcomingMeetings[collectionViewItem!].joiners?.removeAll { $0.uid == friend.user.uid }
            }
        }
    }
    
    func isSelected(_ friend: Friend) -> Bool {
        if let index = index {
            if self.section == 0 {
                return todayMeetings[index].joiners?.contains(where: { $0.uid == friend.user.uid }) ?? false
            } else if self.section == 1 {
                return upcomingMeetings[collectionViewItem!].joiners?.contains(where: { $0.uid == friend.user.uid }) ?? false
            }
        }
        return false
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == selectedName {
            if let index = index {
                if self.section == 0 {
                    return todayMeetings[index].joiners?.count ?? 0
                } else if self.section == 1 {
                    return upcomingMeetings[collectionViewItem!].joiners?.count ?? 0
                }
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == selectedName {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditMeetingSelectFriendsNameCell", for: indexPath) as! EditMeetingSelectFriendsNameCollectionViewCell
            
            var joiners: [User] = []
            
            if self.section == 0 {
                joiners = todayMeetings[index!].joiners ?? []
            } else if self.section == 1 {
                joiners = upcomingMeetings[collectionViewItem!].joiners ?? []
            }
            
            let user = joiners[indexPath.item]
            
            if let friend = Friends.first(where: { $0.user.uid == user.uid }) {
                cell.selectedName.text = friend.user.nickName
                cell.onDeleteButtonTapped = { [weak self] in
                    self?.removeFriend(friend)
                    self?.selectedName.reloadData()
                    self?.favTable.reloadData()
                    self?.allTable.reloadData()
                }
            }
            
            return cell
        }
        return UICollectionViewCell()
    }

    func removeFriendByUID(_ uid: String) {
        if let friend = Friends.first(where: { $0.user.uid == uid }) {
            removeFriend(friend)
        }
        selectedName.reloadData()
        favTable.reloadData()
        allTable.reloadData()
    }
}

extension EditMeetingViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == favTable {
            return favFriends.count
        } else {
            return allFriends.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75 // 셀의 높이를 75픽셀로 설정
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == favTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditMeetingSelectFavCell", for: indexPath) as! EditMeetingSelectFavCell
            let friend = favFriends[indexPath.row]
            cell.configure(with: friend, isSelected: isSelected(friend))
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditMeetingSelectAllCell", for: indexPath) as! EditMeetingSelectAllCell
            let friend = allFriends[indexPath.row]
            cell.configure(with: friend, isSelected: isSelected(friend))
            cell.delegate = self
            return cell
        }
    }
}

extension EditMeetingViewController: EditMeetingSelectFavCellDelegate {
    func didTapFavoriteButton(on cell: EditMeetingSelectFavCell) {
        if let indexPath = favTable.indexPath(for: cell) {
            let friend = favFriends[indexPath.row]
            updateFriendState(for: friend)
        }
    }
}

extension EditMeetingViewController: EditMeetingSelectAllCellDelegate {
    func didTapAllButton(on cell: EditMeetingSelectAllCell) {
        if let indexPath = allTable.indexPath(for: cell) {
            let friend = allFriends[indexPath.row]
            updateFriendState(for: friend)
        }
    }
}

protocol EditMeetingSelectFavCellDelegate: AnyObject {
    func didTapFavoriteButton(on cell: EditMeetingSelectFavCell)
}

protocol EditMeetingSelectAllCellDelegate: AnyObject {
    func didTapAllButton(on cell: EditMeetingSelectAllCell)
}

class EditMeetingSelectFavCell: UITableViewCell {
    @IBOutlet var favImg: UIImageView!
    @IBOutlet var favName: UILabel!
    @IBOutlet var favButton: UIButton!
    
    weak var delegate: EditMeetingSelectFavCellDelegate?
    private var friend: Friend?
    
    func configure(with friend: Friend, isSelected: Bool) {
        self.friend = friend
        favName.text = friend.user.nickName
        
        if let str = friend.user.profileImage {
            favImg.setImageFromStringURL(str)
        }
        
        favButton.isSelected = isSelected
        updateButtonImage()
    }
    
    func updateButtonImage() {
        let imageName = favButton.isSelected ? "checkmark.circle.fill" : "checkmark.circle"
        favButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        delegate?.didTapFavoriteButton(on: self)
    }
}

class EditMeetingSelectAllCell: UITableViewCell {
    @IBOutlet var allImg: UIImageView!
    @IBOutlet var allName: UILabel!
    @IBOutlet var allButton: UIButton!
    
    weak var delegate: EditMeetingSelectAllCellDelegate?
    private var friend: Friend?
    
    func configure(with friend: Friend, isSelected: Bool) {
        self.friend = friend
        allName.text = friend.user.nickName
        
        if let url = friend.user.profileImage {
            allImg.setImageFromStringURL(url)
        }
        
        allButton.isSelected = isSelected
        updateButtonImage()
    }
    
    func updateButtonImage() {
        let imageName = allButton.isSelected ? "checkmark.circle.fill" : "checkmark.circle"
        allButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        delegate?.didTapAllButton(on: self)
    }
}


class EditMeetingSelectFriendsNameCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var selectedName: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    var onDeleteButtonTapped: (() -> Void)?
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        onDeleteButtonTapped?()
    }
}
