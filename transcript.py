import os
import sys

from youtube_transcript_api import YouTubeTranscriptApi
import clipman


def get_pure(videoid: str):
    videoid = videoid.split("=")[-1]
    transcript = YouTubeTranscriptApi.get_transcript(videoid, languages=["en", "ru"])

    text = ""
    for el in transcript:
        text += f' {el.get("text")}'
    return text


def main():
    clipman.init()
    
    text = get_pure(sys.argv[1])

    text_to_add = "Summarize everything in the following video (transcript), provide key points and main ideas. No yapping: " 
    to_copy = text_to_add + text
    clipman.copy(to_copy)
    if clipman.paste() == to_copy:
        print("Successfully copied")


main()




    
