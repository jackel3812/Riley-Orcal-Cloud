// Builder Core Module
define(['knockout', 'ojs/ojcore'], function(ko, oj) {
    class BuilderCore {
        constructor() {
            this.nodes = [];
            this.connections = [];
            this.history = [];
            this.historyIndex = -1;
        }

        // Node Management
        addNode(node) {
            this.nodes.push(node);
            this.saveHistoryState();
        }

        removeNode(nodeId) {
            this.nodes = this.nodes.filter(n => n.id !== nodeId);
            this.saveHistoryState();
        }

        // Connection Management
        addConnection(source, target) {
            this.connections.push({ source, target });
            this.saveHistoryState();
        }

        removeConnection(connectionId) {
            this.connections = this.connections.filter(c => c.id !== connectionId);
            this.saveHistoryState();
        }

        // History Management
        saveHistoryState() {
            const state = {
                nodes: [...this.nodes],
                connections: [...this.connections],
                timestamp: Date.now()
            };

            // Remove any future states if we're not at the end
            this.history = this.history.slice(0, this.historyIndex + 1);
            this.history.push(state);
            this.historyIndex++;
        }

        undo() {
            if (this.historyIndex > 0) {
                this.historyIndex--;
                const state = this.history[this.historyIndex];
                this.nodes = [...state.nodes];
                this.connections = [...state.connections];
            }
        }

        redo() {
            if (this.historyIndex < this.history.length - 1) {
                this.historyIndex++;
                const state = this.history[this.historyIndex];
                this.nodes = [...state.nodes];
                this.connections = [...state.connections];
            }
        }

        // Project Management
        saveProject() {
            const project = {
                nodes: this.nodes,
                connections: this.connections,
                version: '1.0'
            };
            return JSON.stringify(project);
        }

        loadProject(projectData) {
            const project = JSON.parse(projectData);
            this.nodes = project.nodes;
            this.connections = project.connections;
            this.saveHistoryState();
        }
    }

    return BuilderCore;
});
