# iOS 26+ speech stack recommendation

## Keep three signals separate

1. **Transcription** answers “what words did the recognizer hear?” Use `AVAudioEngine` → `SpeechAnalyzer` with `SpeechTranscriber(en-US)` and `SpeechDetector`. Show volatile results while the person speaks, then finalize at the detected end of the utterance. Request audio time ranges and transcription confidence. Confidence is ASR confidence, not a pronunciation score.
2. **Pronunciation** answers “how closely did the acoustics match the intended English sounds?” Apple does not expose a turnkey pronunciation scorer in the public SpeechAnalyzer modules. For constrained tasks, run a small quantized Core ML phoneme CTC / forced-alignment model on retained PCM audio, then derive phoneme/word scores using GOP plus duration, stress and pause features. Calibrate against human-rated L2 English recordings across accents before presenting it as consumer-grade.
3. **Appropriateness** answers “did this response fit the situation?” Run deterministic checks first (required words, length and task constraints), then sentence-embedding similarity against several accepted answers. On supported Apple Intelligence devices, an optional Foundation Models request can provide a richer structured explanation later; it must not block the fast result.

## Latency target

The 500–900 ms target after the speaker stops is realistic for a first useful result when transcription already runs during speech and pronunciation plus rules/embeddings begin in parallel at endpoint detection. It is not a defensible hard target for Foundation Models: Apple notes generation may take several seconds. The interface should therefore reveal results in layers:

- During speech: provisional neutral transcript.
- About 0.5–0.9 s after endpoint: finalized transcript, acoustic segment colors, required-word and basic relevance checks.
- Later, when available: optional local-model coaching explanation.

## Recommended V1 stack

- `AVAudioEngine` + Apple `SpeechAnalyzer`, `SpeechTranscriber`, and `SpeechDetector`.
- A compact, warmed, quantized Core ML phoneme model for constrained prompts; initially keep tasks close to a known phrase or small response set.
- NaturalLanguage sentence embeddings plus deterministic rules for instant semantic scoring.
- Foundation Models only as an asynchronous enhancement with availability and timeout fallbacks.
- Consider WhisperKit or sherpa-onnx only for unsupported locales/devices. They are alternate ASR engines, not pronunciation scorers.

## Primary sources

- [WWDC25: Bring advanced speech-to-text to your app](https://developer.apple.com/videos/play/wwdc2025/277/)
- [Apple Speech sample: advanced speech-to-text](https://developer.apple.com/documentation/Speech/bringing-advanced-speech-to-text-capabilities-to-your-app)
- [SpeechDetector](https://developer.apple.com/documentation/speech/speechdetector)
- [Transcription confidence](https://developer.apple.com/documentation/speech/speechtranscriber/resultattributeoption/transcriptionconfidence)
- [NaturalLanguage text similarity](https://developer.apple.com/documentation/naturallanguage/finding-similarities-between-pieces-of-text)
- [WWDC25: Meet the Foundation Models framework](https://developer.apple.com/videos/play/wwdc2025/286/)
- [Core ML](https://developer.apple.com/documentation/coreml)
- [Apple: analyze Core ML performance in Xcode](https://developer.apple.com/documentation/coreml/analyzing-a-core-ml-model-s-performance-in-xcode)
- [Interspeech 2024: phoneme-level GOP confidence](https://www.isca-archive.org/interspeech_2024/cao24b_interspeech.pdf)
- [Interspeech 2025: GOP calibration limitations](https://www.isca-archive.org/interspeech_2025/parikh25b_interspeech.pdf)
