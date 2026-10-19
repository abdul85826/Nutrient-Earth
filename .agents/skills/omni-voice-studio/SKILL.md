---
name: omni-voice-studio
description: >-
  Audio synthesis, speech generation, voice agent architecture, and VoiceStudio pipelines.
  Use when implementing real-time bidirectional audio (Gemini Live API, WebRTC),
  TTS (ElevenLabs, OpenAI Whisper), STT, and voice UI components.
metadata:
  author: ant-agent
  version: "1.0.0"
---

# Omni Voice & Voice Studio Engineering

This skill guides the design and implementation of real-time voice agents, multimodal speech streaming, and automated voice synthesis pipelines.

---

## 1. Real-time Bidirectional Audio Architectures

For low-latency interactive conversations (e.g. Gemini Live API / WebRTC):
- **Transport**: WebSocket / WebRTC data channels for PCM audio streaming (16kHz / 24kHz, 16-bit little-endian).
- **Voice Activity Detection (VAD)**:
  - Run client-side VAD (e.g. Silero VAD or Web Audio API AnalyserNode) to detect speech onset and cut down bandwidth.
  - Implement barge-in / interruption handling: Immediately halt server audio playback when user starts speaking.

---

## 2. Gemini Live Audio Integration Pattern

```typescript
import { GoogleGenAI } from '@google/genai';

export async function initVoiceSession(apiKey: string) {
  const ai = new GoogleGenAI({ apiKey });

  // Connect to Live bidirectional stream
  const session = await ai.aio.liveStream({
    model: 'gemini-2.0-flash-exp',
    config: {
      generationConfig: {
        responseModalities: ['AUDIO'],
        speechConfig: {
          voiceConfig: {
            prebuiltVoiceConfig: {
              voiceName: 'Aoede', // or 'Puck', 'Charon', 'Fenrir'
            },
          },
        },
      },
    },
  });

  return session;
}
```

---

## 3. TTS & Audio Post-Processing (VoiceStudio)

When rendering high-fidelity speech:
1. **Audio Normalization**: Target -16 LUFS for podcasts/mobile voice output to ensure consistent playback volume.
2. **Buffering Strategy**: Stream initial audio chunks with small buffer sizes (<200ms) for fast Time-to-First-Audio (TTFA).
3. **Format Support**:
   - Web: Opus in WebM container or AAC for maximum browser compatibility.
   - Mobile: AAC / MP3.
