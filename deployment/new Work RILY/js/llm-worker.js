// LLM Worker for offline text processing
class LLMProcessor {
    constructor() {
        this.model = null;
        this.tokenizer = null;
    }

    async loadModel(modelPath) {
        // Load GGML model using WebAssembly
        const response = await fetch(modelPath);
        const modelBuffer = await response.arrayBuffer();
        
        // Initialize GGML runtime
        await this.initGGMLRuntime();
        
        // Load model into runtime
        this.model = await this.runtime.loadModel(modelBuffer);
        
        // Initialize tokenizer
        this.tokenizer = new this.runtime.Tokenizer(this.model);
    }

    async generate({ prompt, context, brain, personality, scientific }) {
        if (!this.model) {
            throw new Error('Model not loaded');
        }

        // Prepare generation parameters
        const params = {
            temperature: personality.temperature || 0.7,
            topP: personality.topP || 0.9,
            maxTokens: 200,
            stopTokens: ['</s>', '[END]'],
            brainType: brain,
            scientificMode: scientific
        };

        // Prepare context window
        const contextWindow = this.prepareContext(context);
        
        // Generate response
        const tokens = await this.model.generate(
            this.tokenizer.encode(contextWindow + prompt),
            params
        );

        // Decode response
        const response = this.tokenizer.decode(tokens);

        return {
            text: response,
            tokens: tokens.length
        };
    }

    prepareContext(context) {
        // Format conversation history
        return context.map(([msg, isUser]) => 
            `${isUser ? 'User' : 'Riley'}: ${msg}\n`
        ).join('');
    }

    async initGGMLRuntime() {
        // Initialize GGML WebAssembly runtime
        this.runtime = await import('./ggml-wasm.js');
        await this.runtime.init();
    }
}

// Create worker instance
const llmProcessor = new LLMProcessor();

// Handle messages from main thread
self.onmessage = async function(e) {
    const { type, data } = e.data;

    try {
        switch (type) {
            case 'load':
                await llmProcessor.loadModel(data.modelPath);
                self.postMessage({ type: 'loaded' });
                break;

            case 'generate':
                const response = await llmProcessor.generate(data);
                self.postMessage({ 
                    type: 'response',
                    data: response
                });
                break;

            default:
                throw new Error(`Unknown message type: ${type}`);
        }
    } catch (error) {
        self.postMessage({
            type: 'error',
            error: error.message
        });
    }
};
