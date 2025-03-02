# Chatbox

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Sqflite](https://img.shields.io/badge/Sqflite-FFCA28?style=for-the-badge&logo=sqlite&logoColor=black)
![Ollama](https://img.shields.io/badge/Ollama-000000?style=for-the-badge&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAABq0lEQVR4Ae2XvUoDQRjHfxF9gdwoVRAUFP6D6Ah6iGgoWjL6CF6CF6ChaqXoLDo6C/oIeoQfgHThEBHbKzmy98mfMzuzOTMjEC5n5vZnJ5/zHvu+8M/UXDdF9bdKDvBaADRA9cOA4AfAh2LYyDzAQgDqZzkm7ZTRIG4qHVNE1okYhzjGXYoHaLTxG+kUdBpDQ6/xLfSG2AHkGGxzMm0G6FVcLzfq7fyzrYL0CDmsMJkzPHdbKheNzHD+HzMeKdnGE/V9YKafJvMNiZlAO0cg+saWWmKOB5PM39JgHoA1jB/HMiAYEX9Z1ZG0C0NkFT7FQ6MTOXrChH2/tsSutVW6whN/sdKPgytsRDwbWzTHzAxnSmbAOskqaFeu0CGHpBrAbRqqAO2cGdz2o0QAbADiDtvX4FBdnmHo9vK2nKqnpS0EYH5F2mEToQkwBrFLROUth5IMY7nOGLPM7JAljtuRHcNWA9LYAeTjDqMK1WB4t6MDZGAkprB7PMZ+YZr3Zf8th9yI4XtHpDXAp3s7R8RmOncPhj7L0H02P0WtNcRuH+O7iFV2gEXeN37u8y/VpCEXOAAAAAElFTkSuQmCC)

chatbox is an open-source software that provides a graphical user interface (GUI) for running large language models (LLMs) using the Ollama. This application allows users to interact with various LLM models, send messages, and receive responses in a chat-like interface.

## Working Demo
![Demo](lib/assets/2.gif)

## Screenshots

![Chatbox Screenshot](lib/assets/1.png)
![Chatbox Screenshot](lib/assets/3.png)

## Folder Structure

```
lib/
├── components/
│   ├── sidebar.dart
├── constants/
│   ├── app_colors.dart
│   ├── app_fonts.dart
├── helpers/
│   ├── database_helper.dart
├── models/
│   ├── message_model.dart
├── providers/
│   ├── chat_provider.dart
├── screens/
│   ├── homepage.dart
├── widgets/
│   ├── input_field.dart
│   ├── message_tile.dart
├── assets/
│   ├── 1.png
│   ├── 3.png
├── main.dart
```

## Features

- **Model Selection**: Choose from a list of available LLM models.
- **Interactive Chat**: Send messages and receive responses from the selected model.
- **Real-time Response**: See when the model is generating a response.
- **Copy to Clipboard**: Easily copy messages to your clipboard.
- **Chat History**: Easily resume your chats as your chats are stored locally.

## Getting Started

### Prerequisites

- Flutter SDK (for developers): [Install Flutter](https://flutter.dev/docs/get-started/install)
- Ollama: [Ollama](https://ollama.ai) must be installed in your system.

### Installation

1. Clone the repository:
   ```sh
   git clone https://github.com/udaykumar-dhokia/chatbox.git
   cd chatbox
   ```

2. Install dependencies:
   ```sh
   flutter pub get
   ```

3. Run the application:
   ```sh
   flutter run
   ```

## Usage

1. Select a model from the dropdown menu.
2. Type your message in the input field.
3. Press the send button or hit enter to send the message.
4. View the model's response in the chat interface.

## Resources

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Ollama API Documentation](https://ollama.ai/docs)

For help getting started with Flutter development, view the [online documentation](https://docs.flutter.dev/), which offers tutorials, samples, guidance on mobile development, and a full API reference.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
