# Django Media & AI Chat Platform

This is a full-featured web application built with Django that combines media sharing with real-time public and private chat functionalities. A key feature is the deep integration of a local AI assistant powered by Ollama and the LangChain framework, providing users with a stateful, conversational AI experience. The entire application is containerized with Docker for easy setup and deployment.

## ✨ Features

- **User Authentication**: Secure user registration, login, and logout.
- **Media Sharing**: Authenticated users can upload and share media files (images, videos).
- **Real-Time Public Chat**: A global chat room for all logged-in users, built with Django Channels.
- **Real-Time Private Chat**: Secure, one-on-one chat between users.
- **AI Assistant Integration**:
    - **Dedicated AI Chat Page**: A private, stateful chat section for logged-in users where conversation history is remembered across sessions.
    - **In-Chat Bot Command**: Users can invoke the AI assistant in any public or private chat room by typing `@bot <your query>`.
    - **Model Selection**: Users can choose from available Ollama models for their AI interactions.
- **Stateful Conversations**: Utilizes LangChain's `ConversationBufferMemory` to give the AI assistant a memory of the current conversation, leading to more natural interactions.
- **Dockerized Environment**: The entire stack (Django app and Ollama) is managed by Docker Compose for simple, one-command setup.
- **Customizable Theme**: A light/dark mode toggle for user preference.

## ⚙️ Tech Stack

- **Backend**: Django, Django Channels (for WebSockets), Daphne (ASGI Server)
- **AI Framework**: LangChain, `langchain-community`
- **LLM Service**: Ollama
- **Frontend**: HTML, CSS, vanilla JavaScript
- **Containerization**: Docker, Docker Compose

---

## 🚀 Application Workflow

The application is composed of two main services orchestrated by Docker Compose: `web` and `ollama`.

1.  **Web Service (Django Application)**:
    - Built using the `Dockerfile`, which sets up a Python environment, installs dependencies from `requirements.txt`, and copies the application code.
    - Served by **Daphne**, an ASGI server capable of handling both standard HTTP requests and WebSocket connections.
    - **HTTP Requests**: Django handles all standard web traffic, including user authentication, rendering pages, and serving media files.
    - **WebSocket Connections**: Django Channels takes over for real-time communication. When a user enters a chat room, a WebSocket connection is established with a `ChatConsumer` or `PrivateChatConsumer`. These consumers manage message broadcasting between clients.

2.  **Ollama Service**:
    - Runs the official `ollama/ollama` Docker image.
    - Exposes the Ollama API on a port that is accessible to the `web` service within the Docker network.
    - A Docker volume (`ollama_data`) is used to persist the downloaded LLM models, so you don't have to re-download them every time you restart the container.

3.  **LangChain Integration (The AI Core)**:
    - The `chat/utils.py` file contains the core logic for AI interaction.
    - When a user interacts with the AI (either on the dedicated AI Chat page or via the `@bot` command), the `get_conversation_chain` function is called.
    - This function initializes a **LangChain `LLMChain`**:
        - It connects to the `ollama` service using `ChatOllama`.
        - It creates a `ConversationBufferMemory` object.
        - **Crucially, it loads the past conversation history from the user's Django session into the memory.** This gives the AI context.
    - The user's input is passed to the chain's `predict` method.
    - After the LLM generates a response, the `save_conversation_history` function is called to **save the updated history (including the new user message and AI reply) back into the user's session.**
    - This session-based memory management ensures that each user's conversation with the bot is private and persistent.

---

## 🛠️ Local Setup & Installation

To run this project locally, you need to have Docker and Docker Compose installed.

### 1. Clone the Repository

```bash
git clone <your-repository-url>
cd <repository-directory>
```

### 2. Build and Start the Services

This single command will build the Django image and start both the `web` and `ollama` containers.

```bash
docker-compose up --build
```

The web application will be accessible at `http://localhost:8000`.

### 3. Download an LLM Model

The application needs a model to be available in Ollama. Open a **new terminal** and run the following command to download the `llama3` model (or any other model you prefer).

```bash
docker-compose exec ollama ollama pull llama3
```

*Note: The default model is set to `llama3:latest` in `settings.py`. You can change this or select other downloaded models from the UI.*

### 4. Set Up the Database

The first time you run the application, you need to apply the database migrations.

```bash
docker-compose exec web python manage.py migrate
```

### 5. Create a Superuser (Optional)

To access the Django admin panel, create a superuser.

```bash
docker-compose exec web python manage.py createsuperuser
```

Follow the prompts to create your admin account. You can then log in at `http://localhost:8000/admin`.

### 6. Start Using the App!

Navigate to `http://localhost:8000` in your browser. You can now:
- Sign up for a new account.
- Log in and explore the media sharing features.
- Join the "Public Chat" room.
- Start a private chat with another user.
- Have a stateful conversation on the "AI Chat" page.

To stop the application, press `Ctrl+C` in the terminal where `docker-compose up` is running.