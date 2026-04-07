import argparse
import os
from pathlib import Path
from markdownify import markdownify as md


def convert_file(input_path: str) -> None:
    """Convert an HTML file to Markdown and save it as <original-name>.md"""
    in_file = Path(input_path).expanduser().resolve()

    if not in_file.exists():
        print(f"Error: The file '{in_file}' does not exist.")
        return

    try:
        html_string = in_file.read_text(encoding="utf-8")
        markdown_output = md(html_string, heading_style="atx")

        out_file = in_file.with_suffix(".md")
        out_file.write_text(markdown_output, encoding="utf-8")

        print("--- Conversion Successful ---")
        print(f"Markdown written to: {out_file}")
    except Exception as e:
        print(f"An error occurred: {e}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Convert an HTML file to Markdown.")
    parser.add_argument("-i", "--input", required=True, help="Path to the input HTML file")
    args = parser.parse_args()
    convert_file(args.input)
