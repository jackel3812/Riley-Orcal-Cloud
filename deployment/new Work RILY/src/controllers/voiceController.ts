import * as vscode from 'vscode';
import { RileyClient } from '../client/rileyClient';

export class VoiceController {
    private isRecording: boolean = false;
    private voiceEnabled: boolean;

    constructor(private client: RileyClient) {
        this.voiceEnabled = vscode.workspace.getConfiguration('riley').get('features.voice.enabled', true);
    }

    async toggleVoice(): Promise<void> {
        this.voiceEnabled = !this.voiceEnabled;
        await vscode.workspace.getConfiguration('riley').update('features.voice.enabled', this.voiceEnabled, true);
    }

    async startRecording(): Promise<void> {
        if (!this.voiceEnabled) {
            vscode.window.showWarningMessage('Voice features are disabled');
            return;
        }

        try {
            this.isRecording = true;
            await this.client.callFeature('voice', 'startRecording', {});
        } catch (error) {
            vscode.window.showErrorMessage(`Failed to start recording: ${error}`);
            this.isRecording = false;
        }
    }

    async stopRecording(): Promise<void> {
        if (!this.isRecording) return;

        try {
            const result = await this.client.callFeature('voice', 'stopRecording', {});
            this.isRecording = false;
            return result;
        } catch (error) {
            vscode.window.showErrorMessage(`Failed to stop recording: ${error}`);
            this.isRecording = false;
        }
    }

    async synthesizeSpeech(text: string): Promise<void> {
        if (!this.voiceEnabled) {
            vscode.window.showWarningMessage('Voice features are disabled');
            return;
        }

        try {
            await this.client.callFeature('voice', 'synthesize', { text });
        } catch (error) {
            vscode.window.showErrorMessage(`Failed to synthesize speech: ${error}`);
        }
    }
}
