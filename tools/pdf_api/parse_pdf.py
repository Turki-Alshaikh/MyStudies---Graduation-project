#!/usr/bin/env python3
"""CLI helper to parse a PDF with the local schedule_parser"""
import sys
import json
import os
from pathlib import Path

CURRENT_DIR = Path(__file__).parent
sys.path.insert(0, str(CURRENT_DIR))

try:
    from schedule_parser import ScheduleParser  # type: ignore
except Exception:
    parser_dir = CURRENT_DIR / "parser"
    if parser_dir.exists():
        sys.path.insert(0, str(parser_dir))
    try:
        from schedule_parser import ScheduleParser  # type: ignore
    except Exception as e:
        print(f"Error importing schedule_parser: {e}", file=sys.stderr)
        sys.exit(1)


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 parse_pdf.py <pdf_path>", file=sys.stderr)
        sys.exit(1)

    pdf_path = sys.argv[1]
    if not os.path.exists(pdf_path):
        print(f"Error: PDF file not found: {pdf_path}", file=sys.stderr)
        sys.exit(1)

    try:
        parser = ScheduleParser()
        courses = parser.parse_pdf(pdf_path)
        if courses:
            print(json.dumps(courses, ensure_ascii=False))
        else:
            print("[]", file=sys.stderr)
            sys.exit(1)
    except Exception as e:
        print(f"Error parsing PDF: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()


