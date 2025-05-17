import * as ko from 'knockout';
import { Node, Connection } from './BuilderCore';

export class PropertyPanel {
    private panel: HTMLElement;
    private selectedItem: ko.Observable<Node | Connection | null>;

    constructor(panelElement: HTMLElement) {
        this.panel = panelElement;
        this.selectedItem = ko.observable(null);

        // Subscribe to changes in selected item
        this.selectedItem.subscribe(this.updatePanel.bind(this));
    }

    setSelectedItem(item: Node | Connection | null): void {
        this.selectedItem(item);
    }

    private updatePanel(item: Node | Connection | null): void {
        this.panel.innerHTML = '';
        
        if (!item) {
            return;
        }

        // Create form layout
        const formLayout = document.createElement('oj-form-layout');
        formLayout.setAttribute('label-edge', 'start');
        formLayout.setAttribute('max-columns', '1');

        // Add properties based on item type
        if ('type' in item) {
            // It's a node
            this.addNodeProperties(formLayout, item as Node);
        } else {
            // It's a connection
            this.addConnectionProperties(formLayout, item as Connection);
        }

        this.panel.appendChild(formLayout);
    }

    private addNodeProperties(formLayout: HTMLElement, node: Node): void {
        // Add type field
        const typeField = document.createElement('oj-input-text');
        typeField.setAttribute('label-hint', 'Type');
        typeField.setAttribute('value', node.type);
        typeField.setAttribute('readonly', 'true');
        formLayout.appendChild(typeField);

        // Add custom properties based on node type
        Object.entries(node.properties).forEach(([key, value]) => {
            const field = this.createPropertyField(key, value);
            if (field) {
                formLayout.appendChild(field);
            }
        });
    }

    private addConnectionProperties(formLayout: HTMLElement, connection: Connection): void {
        // Add source and target fields
        const sourceField = document.createElement('oj-input-text');
        sourceField.setAttribute('label-hint', 'Source');
        sourceField.setAttribute('value', connection.sourceId);
        sourceField.setAttribute('readonly', 'true');
        formLayout.appendChild(sourceField);

        const targetField = document.createElement('oj-input-text');
        targetField.setAttribute('label-hint', 'Target');
        targetField.setAttribute('value', connection.targetId);
        targetField.setAttribute('readonly', 'true');
        formLayout.appendChild(targetField);

        // Add type field
        const typeField = document.createElement('oj-select-single');
        typeField.setAttribute('label-hint', 'Type');
        typeField.setAttribute('value', connection.type);
        typeField.setAttribute('data', JSON.stringify([
            { value: 'default', label: 'Default Flow' },
            { value: 'conditional', label: 'Conditional Flow' }
        ]));
        formLayout.appendChild(typeField);
    }

    private createPropertyField(key: string, value: any): HTMLElement | null {
        let field: HTMLElement | null = null;

        switch (typeof value) {
            case 'string':
                field = document.createElement('oj-input-text');
                field.setAttribute('value', value);
                break;
            case 'number':
                field = document.createElement('oj-input-number');
                field.setAttribute('value', value.toString());
                break;
            case 'boolean':
                field = document.createElement('oj-switch');
                field.setAttribute('value', value ? 'true' : 'false');
                break;
            default:
                return null;
        }

        field.setAttribute('label-hint', key);
        return field;
    }
}
