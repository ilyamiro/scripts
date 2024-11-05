import sys
from youtube_transcript_api import YouTubeTranscriptApi
import subprocess

def fetch_transcript(video_id: str, languages=None) -> str:
    if languages is None:
        languages = ["en", "ru"]

    video_id = video_id.split("=")[-1]
    transcript = YouTubeTranscriptApi.get_transcript(video_id, languages=languages)

    return " ".join(entry["text"] for entry in transcript)

def copy_to_clipboard(text: str):
    process = subprocess.Popen(['xclip', '-selection', 'clipboard'], stdin=subprocess.PIPE)
    process.communicate(input=text.encode('utf-8'))

def main():
    video_id = sys.argv[1]
    transcript_text = fetch_transcript(video_id)

    summary_prefix = "Summarize the following video transcript, focusing on key points and main ideas: "
    full_text = summary_prefix + transcript_text
    copy_to_clipboard(full_text)

    copied_text = subprocess.run(['xclip', '-selection', 'clipboard', '-o'], capture_output=True, text=True).stdout
    if copied_text == full_text:
        print("Text successfully copied to clipboard.")

if __name__ == "__main__":
    main()
