import * as vscode from 'vscode';
import { RileyClient } from '../client/rileyClient';

export class ScientificController {
    private scientificModeEnabled: boolean;

    constructor(private client: RileyClient) {
        this.scientificModeEnabled = vscode.workspace.getConfiguration('riley').get('features.scientific.enabled', true);
    }

    async toggleScientificMode(): Promise<void> {
        this.scientificModeEnabled = !this.scientificModeEnabled;
        await vscode.workspace.getConfiguration('riley').update('features.scientific.enabled', this.scientificModeEnabled, true);
        vscode.window.showInformationMessage(`Scientific mode ${this.scientificModeEnabled ? 'enabled' : 'disabled'}`);
    }

    async processMathQuery(query: string): Promise<any> {
        try {
            return await this.client.callFeature('mathematics', 'process', { query });
        } catch (error) {
            vscode.window.showErrorMessage(`Failed to process math query: ${error}`);
        }
    }

    async processPhysicsQuery(query: string): Promise<any> {
        try {
            return await this.client.callFeature('physics', 'process', { query });
        } catch (error) {
            vscode.window.showErrorMessage(`Failed to process physics query: ${error}`);
        }
    }

    async generateInvention(problem: string): Promise<any> {
        try {
            return await this.client.callFeature('invention', 'generate', { problem });
        } catch (error) {
            vscode.window.showErrorMessage(`Failed to generate invention: ${error}`);
        }
    }

    isScientificModeEnabled(): boolean {
        return this.scientificModeEnabled;
    }
}
