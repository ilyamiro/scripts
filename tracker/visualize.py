from collections import defaultdict
import os
import sys
import json
from rich.console import Console
from rich.table import Table
from rich.progress import BarColumn, Progress, TextColumn

time_track_file = os.path.join(os.path.dirname(__file__), "time_tracking.json")

def format_time(seconds):
    hours = seconds // 3600
    minutes = (seconds % 3600) // 60
    seconds = seconds % 60

    # Format each part with two digits and join with colons
    return f"{hours:02}:{minutes:02}:{seconds:02}"


def read_time_tracking_data(file_path):
    time = defaultdict(dict)
    end = defaultdict(lambda: defaultdict(list))
    total_time_topic = defaultdict(int)
    daily_time = defaultdict(lambda: defaultdict(int))

    if os.path.exists(file_path):
        with open(file_path, 'r') as f:
            TRACK_DATA = json.load(f)

            for topic, data in TRACK_DATA.items():
                total_time = data.get('total_time', 0)
                day_of_week = data.get('day', 'unknown')
                date = data.get('date', 'unknown')

                time[date][topic] = {"total_time": total_time, "day": day_of_week}
                total_time_topic[topic] += total_time
                daily_time[date][topic] = total_time

                if 'end_times' in data:
                    end[date][topic] = data['end_times'][-5:]

    return time, end, total_time_topic, daily_time


def visualize_time(time, end):
    if not time:
        print("No data to visualize.")
        return

    console = Console()
    for date, topics in time.items():
        table = Table(title=f"Total Time Spent on {date} ({topics[next(iter(topics))]['day']})", show_lines=True)

        table.add_column("Topic", justify="left", style="cyan")
        table.add_column("Total Time", justify="right", style="green")
        table.add_column("Last 5 Time Periods", justify="left", style="yellow")

        for topic, data in topics.items():
            formatted_time = format_time(data["total_time"])
            time_periods_display = '\n'.join(
                [f"{t['start_time']} - {t['end_time_formatted']}" for t in end[date][topic]]
            ) if topic in end[date] else "No time periods"

            table.add_row(topic, formatted_time, time_periods_display)

        console.print(table)


def visualize_topic_frequency_by_date(daily_time):
    if not daily_time:
        print("No data to visualize.")
        return

    console = Console()
    for date, topics in daily_time.items():
        max_time = max(topics.values())
        console.print(f"[bold magenta]Total Time Spent on {date}[/bold magenta]")

        with Progress(
            TextColumn("{task.description}", justify="right"),
            BarColumn(bar_width=50),
            TextColumn("[bold blue]{task.fields[time_str]}[/]", justify="right"),
            console=console
        ) as progress:
            for topic, time_spent in sorted(topics.items(), key=lambda item: item[1], reverse=True):
                time_str = format_time(time_spent)
                progress.add_task(description=topic, total=max_time, completed=time_spent, time_str=time_str)

        # console.print("\n[bold green]Summary for " + date + ":[/bold green] Shows total time spent on each topic for this date.")


def visualize_topic_frequency_all_time(total_time):
    if not total_time:
        print("No data to visualize.")
        return

    console = Console()
    max_time = max(total_time.values())
    console.print("[bold magenta]Total Time Spent on Topics (All Time)[/bold magenta]")

    with Progress(
        TextColumn("{task.description}", justify="right"),
        BarColumn(bar_width=50),
        TextColumn("[bold blue]{task.fields[time_str]}[/]", justify="right"),
        console=console
    ) as progress:
        for topic, time_spent in sorted(total_time.items(), key=lambda item: item[1], reverse=True):
            time_str = format_time(time_spent)
            progress.add_task(description=topic, total=max_time, completed=time_spent, time_str=time_str)

    # console.print("\n[bold green]Summary:[/bold green] This graph shows the total time spent on each topic across all dates.")


if __name__ == "__main__":
    topic_time, end_times, total_time_per_topic, daily_time_per_topic = read_time_tracking_data(time_track_file)

    if len(sys.argv) > 1 and sys.argv[1] == "graph":
        visualize_topic_frequency_by_date(daily_time_per_topic)
    elif len(sys.argv) > 1 and sys.argv[1] == "graph-full":
        visualize_topic_frequency_all_time(total_time_per_topic)
    else:
        visualize_time(topic_time, end_times)
