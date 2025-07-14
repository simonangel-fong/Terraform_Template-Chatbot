let chatHistory = [];
const API_URL = "https://chatbot-api.arguswatcher.net/agent";
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
function addMessage(content, isUser = false) {
  const messageDiv = document.createElement("div");
  messageDiv.className = `message ${isUser ? "user" : "bot"}`;

  const now = new Date();
  const timeString = now.toLocaleTimeString([], {
    hour: "2-digit",
    minute: "2-digit",
  });

  messageDiv.innerHTML = `
                <div class="message-avatar">${isUser ? "👤" : "🤖"}</div>
                <div class="message-content">
                    ${content}
                    <div class="message-time">${timeString}</div>
                </div>
            `;

  messagesContainer.appendChild(messageDiv);
  scrollToBottom();
}

// Show typing indicator
function showTypingIndicator() {
  typingIndicator.classList.add("active");
  scrollToBottom();
}

// Hide typing indicator
function hideTypingIndicator() {
  typingIndicator.classList.remove("active");
}

// Scroll to bottom
function scrollToBottom() {
  messagesContainer.scrollTop = messagesContainer.scrollHeight;
}

// Send message
async function sendMessage() {
  const message = messageInput.value.trim();
  if (!message) return;

  // Disable send button
  sendButton.disabled = true;

  // Add user message
  addMessage(message, true);

  // Clear input
  messageInput.value = "";
  messageInput.style.height = "auto";

  // Show typing indicator
  showTypingIndicator();

  try {
    // Call the API with the correct endpoint
    const response = await fetch(API_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ user_prompt: message }),
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();

    // Hide typing indicator
    hideTypingIndicator();

    // Check if API call was successful and extract the generated text
    if (data.success && data.generated_text) {
      addMessage(data.generated_text);
    } else {
      addMessage("Sorry, I encountered an error. Please try again.");
    }
  } catch (error) {
    console.error("Error:", error);
    hideTypingIndicator();
    addMessage(
      "Sorry, I'm having trouble connecting right now. Please check your connection and try again."
    );
  } finally {
    // Re-enable send button
    sendButton.disabled = false;
  }
}

// Initialize
document.addEventListener("DOMContentLoaded", function () {
  messageInput.focus();

  // Remove welcome message after first user interaction
  let firstMessage = true;
  messageInput.addEventListener("input", function () {
    if (firstMessage) {
      const welcomeMsg = document.querySelector(".welcome-message");
      if (welcomeMsg) {
        welcomeMsg.style.animation = "slideIn 0.3s ease-out reverse";
        setTimeout(() => welcomeMsg.remove(), 300);
      }
      firstMessage = false;
    }
  });
});
