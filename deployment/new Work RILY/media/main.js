// Riley Chat Webview Script
(function () {
    const vscode = acquireVsCodeApi();
    const messagesContainer = document.getElementById('messages');
    const userInput = document.getElementById('userInput');
    const sendButton = document.getElementById('sendButton');
    const voiceButton = document.getElementById('voiceButton');
    const brainMode = document.getElementById('brainMode');
    const scientificMode = document.getElementById('scientificMode');

    let isRecording = false;

    // Handle sending messages
    function sendMessage() {
        const message = userInput.value.trim();
        if (message) {
            vscode.postMessage({
                type: 'sendMessage',
                message
            });
            userInput.value = '';
        }
    }

    // Handle voice recording
    function toggleVoiceRecording() {
        if (!isRecording) {
            vscode.postMessage({ type: 'startVoice' });
            voiceButton.classList.add('recording');
        } else {
            vscode.postMessage({ type: 'stopVoice' });
            voiceButton.classList.remove('recording');
        }
        isRecording = !isRecording;
    }

    // Handle brain mode switching
    function switchBrainMode(mode) {
        vscode.postMessage({
            type: 'switchBrain',
            mode
        });
    }

    // Handle scientific mode toggle
    function toggleScientificMode() {
        scientificMode.classList.toggle('active');
        vscode.postMessage({
            type: 'toggleScientificMode'
        });
    }

    // Update chat messages
    function updateMessages(messages) {
        messagesContainer.innerHTML = messages.map(msg => `
            <div class="message ${msg.type}">
                <div class="content">${msg.content}</div>
                <div class="timestamp">${new Date(msg.timestamp).toLocaleTimeString()}</div>
            </div>
        `).join('');
        messagesContainer.scrollTop = messagesContainer.scrollHeight;
    }

    // Event listeners
    sendButton.addEventListener('click', sendMessage);
    userInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            sendMessage();
        }
    });
    voiceButton.addEventListener('click', toggleVoiceRecording);
    brainMode.addEventListener('change', (e) => switchBrainMode(e.target.value));
    scientificMode.addEventListener('click', toggleScientificMode);

    // Handle messages from the extension
    window.addEventListener('message', event => {
        const message = event.data;
        switch (message.type) {
            case 'updateChat':
                updateMessages(message.messages);
                break;
        }
    });
})();
