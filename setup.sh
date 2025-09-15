#!/bin/bash

# Создаем виртуальное окружение
python3 -m venv ai_env

# Активируем окружение
source ai_env/bin/activate

# Устанавливаем необходимые пакеты
pip install requests python-dotenv

# Создаем файл для API ключа
echo "INTELLIGENCE_API_KEY=io-v2-eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJvd25lciI6IjY3Y2I5YjQ1LWI5ZjMtNDVkYy1hNzMwLTE2MGNkKWBZebDz2H1u0MaTCvGhkfGPL74TPpQ" > .env

# Создаем основной Python скрипт
cat > ai_chat.py << EOF
import os
import requests
from dotenv import load_dotenv

load_dotenv()

API_KEY = os.getenv('INTELLIGENCE_API_KEY')
BASE_URL = "https://api.intelligence.io.solutions/api/v1"

def get_models():
    response = requests.get(
        f"{BASE_URL}/models",
        headers={"Authorization": f"Bearer {API_KEY}"}
    )
    response.raise_for_status()
    return [model['id'] for model in response.json()['data']]

def chat_completion(model, messages):
    response = requests.post(
        f"{BASE_URL}/chat/completions",
        headers={
            "Authorization": f"Bearer {API_KEY}",
            "Content-Type": "application/json"
        },
        json={
            "model": model,
            "messages": messages
        }
    )
    response.raise_for_status()
    return response.json()['choices'][0]['message']['content']

def main():
    # Получаем список моделей
    models = get_models()
    print("Доступные модели:")
    for i, model in enumerate(models, 1):
        print(f"{i}. {model}")
    
    # Выбираем модель
    while True:
        try:
            choice = int(input("\nВыберите модель (номер): "))
            selected_model = models[choice-1]
            break
        except (ValueError, IndexError):
            print("Неверный выбор. Попробуйте снова.")
    
    # Инициализируем историю сообщений
    messages = [
        {"role": "system", "content": "You are a helpful assistant."}
    ]
    
    # Основной цикл чата
    print("\nНачинаем чат (для выхода введите 'quit')")
    while True:
        user_input = input("\nВы: ")
        
        if user_input.lower() == 'quit':
            break
            
        messages.append({"role": "user", "content": user_input})
        
        try:
            response = chat_completion(selected_model, messages)
            print(f"\nАссистент: {response}")
            messages.append({"role": "assistant", "content": response})
        except Exception as e:
            print(f"Ошибка: {e}")

if __name__ == "__main__":
    main()
EOF

echo "Установка завершена!"
echo "1. Замените your_api_key_here в файле .env на ваш настоящий API ключ"
echo "2. Запустите скрипт: source ai_env/bin/activate && python ai_chat.py"