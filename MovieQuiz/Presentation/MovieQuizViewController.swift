import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    @IBOutlet private weak var imageView: UIImageView!

    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!

    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!

    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    private var alertPresenter: AlertProtocol?
    private var moviePresenter: MovieQuizPresenter?


    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20

        moviePresenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter(controller: self)

        showLoadingIndicator()
        moviePresenter?.loadData()
    }

    // MARK: - Работа с кнопками
    @IBAction private func noButtonClicked(_ sender: Any) {
        buttonState(isEnable: false)
        moviePresenter?.noButtonClicked()
    }

    @IBAction private func yesButtonClicked(_ sender: Any) {
        buttonState(isEnable: false)
        moviePresenter?.yesButtonClicked()
    }

    func buttonState(isEnable state: Bool) {
        noButton.isEnabled = state
        yesButton.isEnabled = state
    }

    // MARK: - Логика индикатора загрузки
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }

    // MARK: - Вывод сообщения пользователю
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor

        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber

        buttonState(isEnable: true)
    }

    func setResultImageSettings(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8

        if isCorrect {
            imageView.layer.borderColor = UIColor.ypGreen?.cgColor
        } else {
            imageView.layer.borderColor = UIColor.ypRed?.cgColor
        }
    }

    func showAlert(alert: AlertModel) {
        alertPresenter?.showAlert(alertModel: alert)
    }

    func showNetworkError(message: String) {
        hideLoadingIndicator()

        let viewModel = AlertModel(
            id: "errorAlert",
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз",
            action: { [weak self]  in
                guard let self = self else {return}
                self.moviePresenter?.loadData()
            }
        )

        alertPresenter?.showAlert(alertModel: viewModel)
    }
}
