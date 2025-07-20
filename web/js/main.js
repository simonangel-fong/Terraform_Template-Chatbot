// Configuration
const API_URL = "https://chatbot.arguswatcher.net/prod/chatbot";

// DOM Elements
const messagesContainer = document.getElementById("messages");
const messageInput = document.getElementById("messageInput");
const sendButton = document.getElementById("sendButton");
const typingIndicator = document.getElementById("typingIndicator");

// Auto-resize textarea
function autoResize(textarea) {
  textarea.style.height = "auto";
  textarea.style.height = Math.min(textarea.scrollHeight, 120) + "px";
}

// Handle Enter key press
function handleKeyPress(event) {
  if (event.key === "Enter" && !event.shiftKey) {
    event.preventDefault();
    sendMessage();
  }
}

// Send quick message
function sendQuickMessage(message) {
  messageInput.value = message;
  sendMessage();
}

// Add message to chat
function addMessage(
  content,
  isUser = false,
  modelInfo = null,
  tokenInfo = null
) {
  const messageDiv = document.createElement("div");
  messageDiv.className = `message ${isUser ? "user" : "assistant"}`;

  const avatar = document.createElement("div");
  avatar.className = "message-avatar";
  avatar.textContent = isUser ? "👤" : "🤖";

  const messageContent = document.createElement("div");
  messageContent.className = "message-content";
  messageContent.innerHTML = formatMessage(content);

  if (!isUser && modelInfo) {
    const modelInfoDiv = document.createElement("div");
    modelInfoDiv.className = "model-info";
    modelInfoDiv.textContent = `Model: ${modelInfo}`;
    messageContent.appendChild(modelInfoDiv);
  }

  if (!isUser && tokenInfo) {
    const tokenInfoDiv = document.createElement("div");
    tokenInfoDiv.className = "token-info";
    tokenInfoDiv.textContent = `Input tokens: ${tokenInfo.input} | Output tokens: ${tokenInfo.output}`;
    messageContent.appendChild(tokenInfoDiv);
  }

  messageDiv.appendChild(avatar);
  messageDiv.appendChild(messageContent);

  messagesContainer.appendChild(messageDiv);
  scrollToBottom();
}

// Format message content
function formatMessage(content) {
  // Simple formatting - you can enhance this
  return content
    .replace(/\*\*(.*?)\*\*/g, "<strong>$1</strong>")
    .replace(/\*(.*?)\*/g, "<em>$1</em>")
    .replace(
      /`(.*?)`/g,
      '<code style="background: #f1f5f9; padding: 2px 4px; border-radius: 4px; font-family: monospace;">$1</code>'
    )
    .replace(/\n/g, "<br>");
}

// Show typing indicator
function showTypingIndicator() {
  typingIndicator.style.display = "flex";
  scrollToBottom();
}

// Hide typing indicator
function hideTypingIndicator() {
  typingIndicator.style.display = "none";
}

// Scroll to bottom of messages
function scrollToBottom() {
  messagesContainer.scrollTop = messagesContainer.scrollHeight;
}

// Show error message
function showError(message) {
  const errorDiv = document.createElement("div");
  errorDiv.className = "error-message";
  errorDiv.textContent = message;
  messagesContainer.appendChild(errorDiv);
  scrollToBottom();
}

// Send message to API
async function sendMessage() {
  const message = messageInput.value.trim();
  if (!message) return;

  // Disable send button and show user message
  sendButton.disabled = true;
  addMessage(message, true);
  messageInput.value = "";
  messageInput.style.height = "auto";

  // Show typing indicator
  showTypingIndicator();

  try {
    const response = await fetch(API_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        user_prompt: message,
      }),
    });

    if (!response.ok) {
      console.log(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();

    // Hide typing indicator
    hideTypingIndicator();

    if (data.success) {
      const tokenInfo = {
        input: data.input_tokens,
        output: data.output_tokens,
      };

      addMessage(data.generated_text, false, data.model_used, tokenInfo);
    } else {
      showError("Failed to get response from AI assistant");
    }
  } catch (error) {
    console.error("Error:", error);
    hideTypingIndicator();
    showError("Connection error. Please try again.");
  } finally {
    sendButton.disabled = false;
  }
}

// Event listeners
messageInput.addEventListener("input", function () {
  autoResize(this);
});

messageInput.addEventListener("keypress", handleKeyPress);
sendButton.addEventListener("click", sendMessage);

// Initialize
document.addEventListener("DOMContentLoaded", function () {
  messageInput.focus();

  // Remove welcome message on first interaction
  let firstMessage = true;
  const originalSendMessage = sendMessage;
  sendMessage = function () {
    if (firstMessage) {
      const welcomeMessage = document.querySelector(".welcome-message");
      if (welcomeMessage) {
        welcomeMessage.style.animation = "fadeOut 0.3s ease-out";
        setTimeout(() => welcomeMessage.remove(), 300);
      }
      firstMessage = false;
    }
    originalSendMessage();
  };
});

// Add fadeOut animation
const style = document.createElement("style");
style.textContent = `
            @keyframes fadeOut {
                from { opacity: 1; transform: translateY(0); }
                to { opacity: 0; transform: translateY(-20px); }
            }
        `;
document.head.appendChild(style);
