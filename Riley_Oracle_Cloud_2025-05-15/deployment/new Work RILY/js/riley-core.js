// Riley Core - Local AI Processing Module
define(['./llm-worker.js', './voice-worker.js'], function(LLMWorker, VoiceWorker) {
    class RileyCore {
        constructor(config) {
            this.config = config;
            this.llmWorker = new LLMWorker();
            this.voiceWorker = new VoiceWorker();
            this.db = null;
            this.initialized = false;
        }

        async initialize() {
            try {
                // Initialize SQLite database
                this.db = await this.initDatabase();
                
                // Load LLM model
                await this.llmWorker.loadModel(
                    `${this.config.modelsPath}/llm/riley-llm.ggml`
                );

                // Load voice models
                await this.voiceWorker.loadModels({
                    tacotron: `${this.config.modelsPath}/voice/tacotron2`,
                    hifiGan: `${this.config.modelsPath}/voice/hifi-gan`
                });

                // Load personality configurations
                this.personalities = await this.loadPersonalities();

                this.initialized = true;
            } catch (error) {
                console.error('Initialization error:', error);
                throw error;
            }
        }

        async initDatabase() {
            const sqlite3 = await import('sql.js');
            const db = new sqlite3.Database();
            
            // Create tables if they don't exist
            db.exec(`
                CREATE TABLE IF NOT EXISTS messages (
                    id INTEGER PRIMARY KEY,
                    content TEXT,
                    timestamp INTEGER,
                    is_user BOOLEAN,
                    context TEXT
                );

                CREATE TABLE IF NOT EXISTS memory (
                    id INTEGER PRIMARY KEY,
                    key TEXT UNIQUE,
                    value TEXT,
                    last_accessed INTEGER
                );
            `);

            return db;
        }

        async loadPersonalities() {
            const response = await fetch(`${this.config.configPath}/personalities.json`);
            return await response.json();
        }

        async processMessage({ text, brain, personality, scientific }) {
            if (!this.initialized) {
                throw new Error('Riley Core not initialized');
            }

            // Store message in history
            await this.storeMessage(text, true);

            // Get conversation context
            const context = await this.getRecentContext();

            // Process with local LLM
            const response = await this.llmWorker.generate({
                prompt: text,
                context: context,
                brain: brain,
                personality: this.personalities[personality],
                scientific: scientific
            });

            // Store response
            await this.storeMessage(response.text, false);

            return response;
        }

        async storeMessage(content, isUser) {
            const timestamp = Date.now();
            this.db.run(
                'INSERT INTO messages (content, timestamp, is_user) VALUES (?, ?, ?)',
                [content, timestamp, isUser]
            );
        }

        async getRecentContext(limit = 10) {
            const result = this.db.exec(`
                SELECT content, is_user 
                FROM messages 
                ORDER BY timestamp DESC 
                LIMIT ${limit}
            `);
            return result[0]?.values || [];
        }

        // Voice Processing
        async startVoiceRecording() {
            return await this.voiceWorker.startRecording();
        }

        async stopVoiceRecording() {
            const audioData = await this.voiceWorker.stopRecording();
            return await this.voiceWorker.transcribe(audioData);
        }

        async synthesizeVoice(text) {
            const audioData = await this.voiceWorker.synthesize(text);
            await this.playAudio(audioData);
        }

        async playAudio(audioData) {
            const audioContext = new (window.AudioContext || window.webkitAudioContext)();
            const audioBuffer = await audioContext.decodeAudioData(audioData);
            const source = audioContext.createBufferSource();
            source.buffer = audioBuffer;
            source.connect(audioContext.destination);
            source.start();
        }
    }

    return RileyCore;
});
