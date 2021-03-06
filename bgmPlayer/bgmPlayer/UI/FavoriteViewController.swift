import UIKit
import PureLayout

class FavoriteViewController: UIViewController {
    
    // MARK: - Properties
    private var videos: [Video] = [Video]()
    
    // MARK: - View Elements
    let tableView: UITableView
    
    // MARK: - Initializers
    init(
        ) {
        
        self.tableView = UITableView.newAutoLayoutView()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        configureNavigationBar()
        addSubviews()
        addConstraints()
        configureSubviews()
    }
    
    override func viewWillAppear(animated: Bool) {
        request()
    }
    
    // MARK: - View Setup
    private func configureNavigationBar() {
        title = "お気に入り"
    }
    
    private func addSubviews() {
        view.addSubview(tableView)
    }
    
    private func configureSubviews() {
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(
            SearchTableViewCell.self,
            forCellReuseIdentifier: String(SearchTableViewCell)
        )
    }
    
    private func addConstraints() {
        tableView.autoPinEdgesToSuperviewEdges()
    }
    
    private func request() {
        let userDefaultsManager = UserDefaultsManager(userDefaultKey: "Favorites")
        self.videos = userDefaultsManager.get()
        self.tableView.reloadData()
    }
    
}


// MARK: - UITableViewDataSource
extension FavoriteViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier( String(SearchTableViewCell) ) as? SearchTableViewCell {
            cell.configureView(videos[indexPath.row])
            
            cell.watchButton.selected = true
            cell.watchButton.tag = indexPath.row
            cell.watchButton.addTarget(
                self,
                action: #selector(didTapWatchButton(_:)),
                forControlEvents: .TouchUpInside
            )
            
            return cell
        }
        return UITableViewCell()
    }
    
    @objc private func didTapWatchButton(sender: UIButton) {
        sender.selected = !sender.selected
        
        let userDefaultsManager = UserDefaultsManager(userDefaultKey: "Favorites")
        if sender.selected {
            userDefaultsManager.save(videos[sender.tag])
        } else {
            userDefaultsManager.delete(videos[sender.tag].videoId)
        }
        
        videos.removeAtIndex(sender.tag)
        tableView.reloadData()
    }

}

// MARK: - UITableViewDelegate
extension FavoriteViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let videoViewController = VideoViewController(video: videos[indexPath.row])
        navigationController?.pushViewController(videoViewController, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(Constants.searchTableViewCellHeight)
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.editing = editing
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let userDefaultsManager = UserDefaultsManager(userDefaultKey: "Favorites")
        userDefaultsManager.delete(videos[indexPath.row].videoId)
        videos.removeAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    }
}
