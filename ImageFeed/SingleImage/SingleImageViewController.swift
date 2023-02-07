import UIKit

final class SingleImageViewController: UIViewController {
    var fullImageUrl: String?
    var image: UIImage! {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        setImage()
    }
    
    
    @IBAction private func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func didTapShareButton(_ sender: Any) {
        let ac = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        present(ac, animated: true, completion: nil)
    }
    
    private func setImage() {
        UIBlockingProgressHUD.show()
        let url = URL(string: fullImageUrl!)
        DispatchQueue.main.async {
            self.imageView.kf.setImage(with: url) { [weak self] result in
                UIBlockingProgressHUD.dismiss()
                guard let self = self else { return }
                switch result {
                case .success(let imageResult):
                    self.rescaleAndCenterImageInScrollView(image: imageResult.image)
//                    self.scrollViewDidZoom(self.scrollView)
                case .failure(let error):
                    self.showError(with: error)
                }
            }
        }
    }
    
    private func showError(with error: Error) {
        let alert = UIAlertController(title: "Что-то пошло не так.", message: "Ошибка - \(error). Попробовать ещё раз?", preferredStyle: .alert)
        let action = UIAlertAction(title: "Не надо", style: .cancel)
        let completion: (UIAlertAction) -> Void = { [weak self] _ in self?.setImage() }
        let actionTwo = UIAlertAction(title: "Повторить", style: .default, handler: completion)
        alert.addAction(action)
        alert.addAction(actionTwo)
        self.present(alert, animated: true)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
   private func rescaleAndCenterImageInScrollView(image: UIImage) {
            let minZoomScale = scrollView.minimumZoomScale
            let maxZoomScale = scrollView.maximumZoomScale
            view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
            let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
            scrollView.setZoomScale(scale, animated: false)
            scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        func centerImageInScrollView(image: UIImage) {
            let visibleRectSize = scrollView.bounds.size
            let imageSize = image.size
            let hScale = visibleRectSize.width / imageSize.width
            let vScale = visibleRectSize.height / imageSize.height
            let newContentSize = scrollView.contentSize
            let x = (newContentSize.width - visibleRectSize.width) / 2
            let y = (newContentSize.height - visibleRectSize.height) / 2
            scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
        }
    }
}
