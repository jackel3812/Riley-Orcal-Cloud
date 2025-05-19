import * as vscode from 'vscode';
import { RileyClient } from '../client/rileyClient';
import { BrainController } from '../controllers/brainController';
import { VoiceController } from '../controllers/voiceController';
import { ScientificController } from '../controllers/scientificController';

export class RileyWebviewProvider implements vscode.WebviewViewProvider {
    private _view?: vscode.WebviewView;
    private _messages: any[] = [];

    constructor(
        private readonly _extensionUri: vscode.Uri,
        private readonly _client: RileyClient,
        private readonly _brainController: BrainController,
        private readonly _voiceController: VoiceController,
        private readonly _scientificController: ScientificController
    ) {}

    public resolveWebviewView(
        webviewView: vscode.WebviewView,
        context: vscode.WebviewViewResolveContext,
        _token: vscode.CancellationToken,
    ) {
        this._view = webviewView;

        webviewView.webview.options = {
            enableScripts: true,
            localResourceRoots: [this._extensionUri]
        };

        webviewView.webview.html = this._getHtmlForWebview(webviewView.webview);

        webviewView.webview.onDidReceiveMessage(async (data) => {
            switch (data.type) {
                case 'sendMessage':
                    await this._handleMessage(data.message);
                    break;
                case 'switchBrain':
                    await this._brainController.switchMode(data.mode);
                    break;
                case 'startVoice':
                    await this._voiceController.startRecording();
                    break;
                case 'stopVoice':
                    const transcription = await this._voiceController.stopRecording();
                    if (transcription) {
                        await this._handleMessage(transcription);
                    }
                    break;
                case 'scientificQuery':
                    if (data.subject === 'math') {
                        await this._scientificController.processMathQuery(data.query);
                    } else if (data.subject === 'physics') {
                        await this._scientificController.processPhysicsQuery(data.query);
                    }
                    break;
                case 'generateInvention':
                    await this._scientificController.generateInvention(data.problem);
                    break;
            }
        });
    }

    private async _handleMessage(message: string) {
        try {
            const response = await this._client.sendMessage(message, {
                brainMode: this._brainController.getCurrentMode(),
                scientificMode: this._scientificController.isScientificModeEnabled()
            });

            this._messages.push({
                type: 'user',
                content: message,
                timestamp: new Date()
            });

            this._messages.push({
                type: 'riley',
                content: response.content,
                timestamp: new Date()
            });

            this._updateWebview();

            if (response.shouldSpeak) {
                await this._voiceController.synthesizeSpeech(response.content);
            }
        } catch (error) {
            vscode.window.showErrorMessage(`Failed to send message: ${error}`);
        }
    }

    private _updateWebview() {
        if (this._view) {
            this._view.webview.postMessage({
                type: 'updateChat',
                messages: this._messages
            });
        }
    }

    private _getHtmlForWebview(webview: vscode.Webview): string {
        const scriptUri = webview.asWebviewUri(vscode.Uri.joinPath(this._extensionUri, 'media', 'main.js'));
        const styleUri = webview.asWebviewUri(vscode.Uri.joinPath(this._extensionUri, 'media', 'style.css'));

        return `<!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <link href="${styleUri}" rel="stylesheet">
                <title>Riley Chat</title>
            </head>
            <body>
                <div class="chat-container">
                    <div class="controls">
                        <select id="brainMode">
                            <option value="default">Default</option>
                            <option value="scientific">Scientific</option>
                            <option value="creative">Creative</option>
                            <option value="analytical">Analytical</option>
                        </select>
                        <button id="voiceButton">
                            <i class="codicon codicon-mic"></i>
                        </button>
                        <button id="scientificMode">
                            <i class="codicon codicon-beaker"></i>
                        </button>
                    </div>
                    <div class="messages" id="messages"></div>
                    <div class="input-container">
                        <textarea id="userInput" placeholder="Type your message..."></textarea>
                        <button id="sendButton">
                            <i class="codicon codicon-send"></i>
                        </button>
                    </div>
                </div>
                <script src="${scriptUri}"></script>
            </body>
            </html>`;
    }
}
