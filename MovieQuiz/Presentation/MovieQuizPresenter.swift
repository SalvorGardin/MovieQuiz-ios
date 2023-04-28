//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Aleksey Shaposhnikov on 27.04.2023.
//

import Foundation
import UIKit

final class MovieQuizPresenter: MovieQuizPresenterProtocol, QuestionFactoryDelegate {
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticService?
    weak var viewController: MovieQuizViewControllerProtocol?
    var currentQuestion: QuizQuestion?

    init(viewController: MovieQuizViewControllerProtocol = MovieQuizViewController()) {
        self.viewController = viewController

        statisticService = StatisticServiceImplementation()

        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }

    private var questionNumber: Int = 1
    private let questionsAmount: Int = 10
    private var correctAnswers: Int = 0

    // MARK: - Работа с моделями
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let viewModel = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(questionNumber)/\(questionsAmount)"
            )

        return viewModel
    }

    // MARK: - Работа с кнопками
    func noButtonClicked() {
        checkAnswer(buttonValue: false)
    }

    func yesButtonClicked() {
        checkAnswer(buttonValue: true)
    }

    // MARK: - Работа с вопросами
    private func checkAnswer(buttonValue: Bool) {
        guard let currentQuestion = currentQuestion else {return}

        showAnswerResult(isCorrect: (buttonValue == currentQuestion.correctAnswer))
    }

    func isLastQuestion() -> Bool {
        return questionNumber + 1 > questionsAmount
    }

    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }

    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }

    func loadData() {
        questionFactory?.loadData()
    }

    // Вывод сообщений пользователю
    func showAnswerResult(isCorrect: Bool) {
        viewController?.setResultImageSettings(isCorrect: isCorrect)
        if isCorrect {
            correctAnswers += 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestion()
        }
    }

    private func showNextQuestion() {
        if !checkQuestionNumbers() {
            showResults()
        } else {
            questionNumber += 1
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.questionFactory?.requestNextQuestion()
            }
        }
    }

    private func checkQuestionNumbers() -> Bool {
        if isLastQuestion() {
            return false
        }
        return true
    }

    private func showResults() {
        statisticService?.store(correct: correctAnswers, total: questionNumber)

        let alertModel = AlertModel(
            id: "resultAlert",
            title: "Этот раунд окончен",
            message: createResultMessage(),
            buttonText: "Сыграть ещё раз",
            action: { [weak self]  in
                guard let self = self else {return}
                self.questionNumber = 1
                self.correctAnswers = 0
                self.questionFactory?.loadData()
            })

        viewController?.showAlert(alert: alertModel)
    }

    private func createResultMessage() -> String {
        guard let statisticService = statisticService else {return ""}
        guard let bestGame = statisticService.bestGame else {return ""}

        let currentResult = "Ваш результат: \(correctAnswers) из \(questionsAmount)"

        let totalGameNumber = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let bestResult = "Рекорд:\(bestGame.correct)\\\(bestGame.total)" + " (\(bestGame.date.dateTimeString))"
        let averageAccuracy = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"

        let resultMessage = "\(currentResult) \n\(totalGameNumber) \n\(bestResult) \n\(averageAccuracy)"

        return resultMessage
    }
}
