import * as ko from 'knockout';
import { Node, Connection } from './BuilderCore';

export class CanvasManager {
    private canvas: HTMLElement;
    private zoom: ko.Observable<number>;
    private offset: ko.Observable<{ x: number; y: number }>;
    private isDragging: boolean;
    private selectedNode: ko.Observable<Node | null>;

    constructor(canvasElement: HTMLElement) {
        this.canvas = canvasElement;
        this.zoom = ko.observable(1);
        this.offset = ko.observable({ x: 0, y: 0 });
        this.isDragging = false;
        this.selectedNode = ko.observable(null);

        this.initializeEventListeners();
    }

    private initializeEventListeners(): void {
        this.canvas.addEventListener('mousedown', this.handleMouseDown.bind(this));
        this.canvas.addEventListener('mousemove', this.handleMouseMove.bind(this));
        this.canvas.addEventListener('mouseup', this.handleMouseUp.bind(this));
        this.canvas.addEventListener('wheel', this.handleWheel.bind(this));
    }

    private handleMouseDown(event: MouseEvent): void {
        this.isDragging = true;
        const node = this.findNodeAtPosition(event.clientX, event.clientY);
        if (node) {
            this.selectedNode(node);
        } else {
            this.selectedNode(null);
        }
    }

    private handleMouseMove(event: MouseEvent): void {
        if (this.isDragging && this.selectedNode()) {
            const node = this.selectedNode();
            if (node) {
                node.position.x += event.movementX / this.zoom();
                node.position.y += event.movementY / this.zoom();
                this.redrawCanvas();
            }
        }
    }

    private handleMouseUp(): void {
        this.isDragging = false;
    }

    private handleWheel(event: WheelEvent): void {
        event.preventDefault();
        const delta = event.deltaY > 0 ? 0.9 : 1.1;
        const newZoom = this.zoom() * delta;
        if (newZoom >= 0.1 && newZoom <= 3) {
            this.zoom(newZoom);
            this.redrawCanvas();
        }
    }

    private findNodeAtPosition(x: number, y: number): Node | null {
        // Implementation would check if coordinates are within any node bounds
        return null;
    }

    redrawCanvas(): void {
        // Clear canvas
        this.canvas.innerHTML = '';

        // Apply zoom and offset transformations
        const transform = `scale(${this.zoom()}) translate(${this.offset().x}px, ${this.offset().y}px)`;
        this.canvas.style.transform = transform;

        // Render nodes and connections
        // Implementation would create and position node elements and draw SVG connections
    }

    addNode(node: Node): void {
        // Create DOM element for node
        const nodeElement = document.createElement('div');
        nodeElement.className = `diagram-node node-${node.type}`;
        nodeElement.style.left = `${node.position.x}px`;
        nodeElement.style.top = `${node.position.y}px`;
        nodeElement.innerHTML = `<div class="node-content">${node.type}</div>`;
        
        this.canvas.appendChild(nodeElement);
    }

    addConnection(connection: Connection): void {
        // Create SVG element for connection
        const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
        // Implementation would calculate path between nodes and draw connection line
    }

    updateNodePosition(nodeId: string, x: number, y: number): void {
        const nodeElement = this.canvas.querySelector(`[data-node-id="${nodeId}"]`);
        if (nodeElement) {
            nodeElement.setAttribute('style', `left: ${x}px; top: ${y}px`);
        }
    }

    getSelectedNode(): ko.Observable<Node | null> {
        return this.selectedNode;
    }
}
