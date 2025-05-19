import * as vscode from 'vscode';
import axios from 'axios';
import WebSocket from 'ws';

export class RileyClient {
    private config: vscode.WorkspaceConfiguration;
    private ws: WebSocket | null = null;
    private token: string | null = null;

    constructor() {
        this.config = vscode.workspace.getConfiguration('riley');
    }

    async initialize(): Promise<void> {
        try {
            await this.authenticate();
            await this.connectWebSocket();
        } catch (error) {
            vscode.window.showErrorMessage('Failed to initialize Riley client');
            console.error(error);
        }
    }

    private async authenticate(): Promise<void> {
        const response = await axios.post(`${this.config.get('apiUrl')}/auth`, {
            client_id: this.config.get('clientId'),
            client_secret: this.config.get('clientSecret'),
            scope: 'full_access'
        });
        this.token = response.data.access_token;
    }

    private async connectWebSocket(): Promise<void> {
        if (!this.token) return;

        this.ws = new WebSocket(`${this.config.get('apiUrl')}/ws`, {
            headers: { Authorization: `Bearer ${this.token}` }
        });

        this.ws.on('open', () => {
            console.log('Connected to Riley WebSocket');
        });

        this.ws.on('error', (error) => {
            console.error('WebSocket error:', error);
            vscode.window.showErrorMessage('Lost connection to Riley');
        });
    }

    async sendMessage(message: string, context: any = {}): Promise<any> {
        if (this.ws?.readyState === WebSocket.OPEN) {
            return new Promise((resolve, reject) => {
                this.ws!.send(JSON.stringify({
                    type: 'message',
                    content: message,
                    context
                }));

                const handler = (data: WebSocket.Data) => {
                    const response = JSON.parse(data.toString());
                    if (response.type === 'response') {
                        this.ws!.off('message', handler);
                        resolve(response);
                    }
                };

                this.ws!.on('message', handler);
            });
        } else {
            const response = await axios.post(`${this.config.get('apiUrl')}/chat`, {
                message,
                context
            }, {
                headers: { Authorization: `Bearer ${this.token}` }
            });
            return response.data;
        }
    }

    async callFeature(feature: string, operation: string, data: any): Promise<any> {
        const response = await axios.post(
            `${this.config.get('apiUrl')}/api/${feature}/${operation}`,
            data,
            {
                headers: { Authorization: `Bearer ${this.token}` }
            }
        );
        return response.data;
    }
}
