#include <iostream>
#include <vector>
#include <string>
#include <cstdlib>
#include <ctime>
#include <algorithm>

using namespace std;

// Структура для представления карты
struct Card {
    string rank;
    string suit;
    int value;
};

// Функция для создания колоды карт
vector<Card> createDeck() {
    vector<string> suits = {"♥", "♦", "♣", "♠"};
    vector<string> ranks = {"2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"};
    vector<int> values = {2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10, 11};
    
    vector<Card> deck;
    
    for (const auto& suit : suits) {
        for (int i = 0; i < ranks.size(); i++) {
            Card card;
            card.rank = ranks[i];
            card.suit = suit;
            card.value = values[i];
            deck.push_back(card);
        }
    }
    
    return deck;
}

// Функция для перемешивания колоды
void shuffleDeck(vector<Card>& deck) {
    srand(time(0));
    random_shuffle(deck.begin(), deck.end());
}

// Функция для подсчета очков в руке
int calculateHandValue(const vector<Card>& hand) {
    int value = 0;
    int aces = 0;
    
    for (const auto& card : hand) {
        value += card.value;
        if (card.rank == "A") {
            aces++;
        }
    }
    
    // Если сумма больше 21 и есть тузы, учитываем их как 1 вместо 11
    while (value > 21 && aces > 0) {
        value -= 10;
        aces--;
    }
    
    return value;
}

// Функция для отображения руки
void displayHand(const vector<Card>& hand, bool isDealer = false, bool hideFirstCard = false) {
    if (isDealer) {
        cout << "Дилер: ";
    } else {
        cout << "Вы: ";
    }
    
    for (int i = 0; i < hand.size(); i++) {
        if (hideFirstCard && i == 0) {
            cout << "[XX] ";
        } else {
            cout << "[" << hand[i].rank << hand[i].suit << "] ";
        }
    }
    
    if (!hideFirstCard) {
        if (isDealer) {
            cout << " (" << calculateHandValue(hand) << ")";
        } else {
            cout << " (" << calculateHandValue(hand) << ")";
        }
    }
    
    cout << endl;
}

// Основная функция игры
void playBlackjack() {
    vector<Card> deck = createDeck();
    shuffleDeck(deck);
    
    vector<Card> playerHand;
    vector<Card> dealerHand;
    
    // Раздача первых двух карт
    playerHand.push_back(deck.back());
    deck.pop_back();
    dealerHand.push_back(deck.back());
    deck.pop_back();
    playerHand.push_back(deck.back());
    deck.pop_back();
    dealerHand.push_back(deck.back());
    deck.pop_back();
    
    // Отображение начальных рук
    cout << "\n=== НАЧАЛО РАЗДАЧИ ===\n";
    displayHand(dealerHand, true, true);
    displayHand(playerHand, false);
    
    // Ход игрока
    bool playerBusted = false;
    while (true) {
        cout << "\nВыберите действие:\n";
        cout << "1 - Взять карту\n";
        cout << "2 - Остановиться\n";
        cout << "Ваш выбор: ";
        
        int choice;
        cin >> choice;
        
        if (choice == 1) {
            playerHand.push_back(deck.back());
            deck.pop_back();
            displayHand(dealerHand, true, true);
            displayHand(playerHand, false);
            
            if (calculateHandValue(playerHand) > 21) {
                cout << "\nПеребор! Вы проиграли.\n";
                playerBusted = true;
                break;
            }
        } else if (choice == 2) {
            break;
        } else {
            cout << "Неверный выбор. Попробуйте снова.\n";
        }
    }
    
    // Ход дилера, если игрок не проиграл
    if (!playerBusted) {
        cout << "\n--- ХОД ДИЛЕРА ---\n";
        displayHand(dealerHand, true);
        displayHand(playerHand, false);
        
        while (calculateHandValue(dealerHand) < 17) {
            cout << "\nДилер берет карту...\n";
            dealerHand.push_back(deck.back());
            deck.pop_back();
            displayHand(dealerHand, true);
            displayHand(playerHand, false);
            
            if (calculateHandValue(dealerHand) > 21) {
                cout << "\nДилер перебрал! Вы выиграли!\n";
                return;
            }
        }
        
        // Сравнение результатов
        int playerValue = calculateHandValue(playerHand);
        int dealerValue = calculateHandValue(dealerHand);
        
        cout << "\n=== РЕЗУЛЬТАТ ===\n";
        cout << "Ваши очки: " << playerValue << endl;
        cout << "Очки дилера: " << dealerValue << endl;
        
        if (playerValue > dealerValue) {
            cout << "Вы выиграли!\n";
        } else if (playerValue < dealerValue) {
            cout << "Вы проиграли.\n";
        } else {
            cout << "Ничья!\n";
        }
    }
}

// Главная функция
int main() {
    setlocale(LC_ALL, "Russian");
    
    cout << "Добро пожаловать в Blackjack!\n";
    
    while (true) {
        playBlackjack();
        
        cout << "\nХотите сыграть еще раз? (1 - Да, 0 - Нет): ";
        int playAgain;
        cin >> playAgain;
        
        if (playAgain != 1) {
            cout << "Спасибо за игру! До свидания!\n";
            break;
        }
        
        cout << "\n=================================\n";
    }
    
    return 0;
}