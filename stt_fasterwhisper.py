import argparse
import os
import sys

# Fix UTF-8 encoding on Windows
if sys.platform == "win32":
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')


def main() -> int:
    parser = argparse.ArgumentParser(description="Local STT for OpenClaw media.audio (faster-whisper).")
    parser.add_argument("--input", required=True, help="Path to audio file")
    parser.add_argument("--model", default="base", help="Whisper model size/name (default: base)")
    parser.add_argument("--language", default="zh", help="Language hint (default: zh)")
    parser.add_argument("--task", default="transcribe", choices=["transcribe", "translate"])
    args = parser.parse_args()

    audio_path = os.path.abspath(args.input)
    if not os.path.exists(audio_path):
        print(f"Audio file not found: {audio_path}", file=sys.stderr)
        return 2

    # Make cache location stable across users (e.g. when the Gateway runs as SYSTEM).
    state_dir = os.environ.get("OPENCLAW_STATE_DIR") or r"C:\Users\Administrator\.openclaw"
    hf_home = os.path.join(state_dir, "cache", "huggingface")
    os.makedirs(hf_home, exist_ok=True)
    os.environ.setdefault("HF_HOME", hf_home)
    os.environ.setdefault("HUGGINGFACE_HUB_CACHE", os.path.join(hf_home, "hub"))

    try:
        from faster_whisper import WhisperModel
    except Exception as exc:
        print(f"Missing dependency faster-whisper: {exc}", file=sys.stderr)
        return 3

    try:
        model = WhisperModel(args.model, device="cpu", compute_type="int8")
        segments, _info = model.transcribe(
            audio_path,
            task=args.task,
            language=args.language if args.language else None,
            vad_filter=True,
        )
        text_parts: list[str] = []
        for seg in segments:
            if seg.text:
                text_parts.append(seg.text.strip())
        text = " ".join([p for p in text_parts if p]).strip()
        if text:
            print(text)
        return 0
    except Exception as exc:
        print(f"Transcription failed: {exc}", file=sys.stderr)
        return 4


if __name__ == "__main__":
    raise SystemExit(main())

