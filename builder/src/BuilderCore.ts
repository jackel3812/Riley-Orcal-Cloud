import * as ko from 'knockout';

export interface Node {
    id: string;
    type: string;
    properties: any;
    position: { x: number; y: number };
}

export interface Connection {
    id: string;
    sourceId: string;
    targetId: string;
    type: string;
}

export class BuilderCore {
    private nodes: ko.ObservableArray<Node>;
    private connections: ko.ObservableArray<Connection>;
    private history: Array<{ nodes: Node[]; connections: Connection[] }>;
    private historyIndex: number;

    constructor() {
        this.nodes = ko.observableArray([]);
        this.connections = ko.observableArray([]);
        this.history = [];
        this.historyIndex = -1;
        this.saveHistoryState();
    }

    addNode(node: Node): void {
        this.nodes.push(node);
        this.saveHistoryState();
    }

    removeNode(nodeId: string): void {
        this.nodes.remove(n => n.id === nodeId);
        // Remove associated connections
        this.connections.remove(c => c.sourceId === nodeId || c.targetId === nodeId);
        this.saveHistoryState();
    }

    addConnection(connection: Connection): void {
        this.connections.push(connection);
        this.saveHistoryState();
    }

    removeConnection(connectionId: string): void {
        this.connections.remove(c => c.id === connectionId);
        this.saveHistoryState();
    }

    private saveHistoryState(): void {
        const state = {
            nodes: this.nodes().slice(),
            connections: this.connections().slice()
        };

        // Remove any future states if we're not at the end
        this.history = this.history.slice(0, this.historyIndex + 1);
        this.history.push(state);
        this.historyIndex++;
    }

    undo(): void {
        if (this.historyIndex > 0) {
            this.historyIndex--;
            const state = this.history[this.historyIndex];
            this.nodes(state.nodes);
            this.connections(state.connections);
        }
    }

    redo(): void {
        if (this.historyIndex < this.history.length - 1) {
            this.historyIndex++;
            const state = this.history[this.historyIndex];
            this.nodes(state.nodes);
            this.connections(state.connections);
        }
    }

    saveProject(): string {
        const project = {
            nodes: this.nodes(),
            connections: this.connections(),
            version: '1.0.0'
        };
        return JSON.stringify(project, null, 2);
    }

    loadProject(projectData: string): void {
        const project = JSON.parse(projectData);
        this.nodes(project.nodes);
        this.connections(project.connections);
        this.saveHistoryState();
    }

    getNodes(): ko.ObservableArray<Node> {
        return this.nodes;
    }

    getConnections(): ko.ObservableArray<Connection> {
        return this.connections;
    }
}
