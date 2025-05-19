// Voice Worker for offline speech processing
class VoiceProcessor {
    constructor() {
        this.tacotron = null;
        this.hifiGan = null;
        this.whisper = null;
        this.recorder = null;
        this.audioContext = null;
    }

    async loadModels({ tacotron, hifiGan }) {
        // Load Tacotron2 model
        const tacotronResponse = await fetch(tacotron);
        const tacotronBuffer = await tacotronResponse.arrayBuffer();
        this.tacotron = await this.initTacotron(tacotronBuffer);

        // Load HiFi-GAN model
        const hifiGanResponse = await fetch(hifiGan);
        const hifiGanBuffer = await hifiGanResponse.arrayBuffer();
        this.hifiGan = await this.initHifiGan(hifiGanBuffer);

        // Initialize audio processing
        await this.initAudioContext();
    }

    async initAudioContext() {
        // Initialize WebAudio context
        this.audioContext = new (self.AudioContext || self.webkitAudioContext)();
        await this.audioContext.audioWorklet.addModule('voice-processor.js');
    }

    async startRecording() {
        if (!this.audioContext) {
            throw new Error('Audio context not initialized');
        }

        // Create audio worklet node
        this.recorder = new AudioWorkletNode(
            this.audioContext,
            'voice-recorder-processor'
        );

        // Start recording
        const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
        const source = this.audioContext.createMediaStreamSource(stream);
        source.connect(this.recorder);
        this.recorder.connect(this.audioContext.destination);
    }

    async stopRecording() {
        if (!this.recorder) {
            throw new Error('No active recording');
        }

        // Get recorded audio buffer
        const audioData = await this.recorder.port.postMessage({ type: 'getBuffer' });
        
        // Clean up
        this.recorder.disconnect();
        this.recorder = null;

        return audioData;
    }

    async transcribe(audioData) {
        if (!this.whisper) {
            // Load Whisper model if not loaded
            this.whisper = await this.initWhisper();
        }

        // Process audio with Whisper
        const result = await this.whisper.transcribe(audioData);
        return result.text;
    }

    async synthesize(text) {
        if (!this.tacotron || !this.hifiGan) {
            throw new Error('Voice models not loaded');
        }

        // Generate mel-spectrogram with Tacotron2
        const melSpec = await this.tacotron.generate(text);

        // Convert to audio with HiFi-GAN
        const audioData = await this.hifiGan.generate(melSpec);

        return audioData;
    }

    async initTacotron(modelBuffer) {
        // Initialize Tacotron2 ONNX runtime
        const runtime = await import('./onnx-runtime-wasm.js');
        await runtime.init();

        return new runtime.InferenceSession(modelBuffer);
    }

    async initHifiGan(modelBuffer) {
        // Initialize HiFi-GAN ONNX runtime
        const runtime = await import('./onnx-runtime-wasm.js');
        await runtime.init();

        return new runtime.InferenceSession(modelBuffer);
    }

    async initWhisper() {
        // Initialize Whisper model
        const whisperRuntime = await import('./whisper-wasm.js');
        await whisperRuntime.init();

        return new whisperRuntime.WhisperProcessor();
    }
}

// Create worker instance
const voiceProcessor = new VoiceProcessor();

// Handle messages from main thread
self.onmessage = async function(e) {
    const { type, data } = e.data;

    try {
        switch (type) {
            case 'loadModels':
                await voiceProcessor.loadModels(data);
                self.postMessage({ type: 'loaded' });
                break;

            case 'startRecording':
                await voiceProcessor.startRecording();
                self.postMessage({ type: 'recording' });
                break;

            case 'stopRecording':
                const audioData = await voiceProcessor.stopRecording();
                self.postMessage({ 
                    type: 'audioData',
                    data: audioData 
                });
                break;

            case 'transcribe':
                const text = await voiceProcessor.transcribe(data);
                self.postMessage({
                    type: 'transcription',
                    data: text
                });
                break;

            case 'synthesize':
                const audio = await voiceProcessor.synthesize(data);
                self.postMessage({
                    type: 'audio',
                    data: audio
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
