import * as vscode from 'vscode';
import { RileyClient } from '../client/rileyClient';

export class BrainController {
    private currentMode: string = 'default';

    constructor(private client: RileyClient) {}

    async switchMode(mode: string): Promise<void> {
        try {
            await this.client.callFeature('brain', 'switch', { mode });
            this.currentMode = mode;
            vscode.window.showInformationMessage(`Switched to ${mode} brain mode`);
        } catch (error) {
            vscode.window.showErrorMessage(`Failed to switch brain mode: ${error}`);
        }
    }

    getCurrentMode(): string {
        return this.currentMode;
    }
}
