#!/usr/bin/env python3
"""Send complete Codex replies to the desktop notification service."""
import html
import json
import re
import subprocess
import sys


def plain_text(message):
    # Keep code and link labels, removing Markdown decoration from the popup.
    message = re.sub(r"(?m)^\s*```[^\n]*$", "", message)
    message = re.sub(r"!?\[([^]\n]+)\]\([^\n]*?\)", r"\1", message)
    message = re.sub(r"`([^`]+)`", r"\1", message)
    message = re.sub(r"\*\*(.+?)\*\*|__(.+?)__", lambda m: m[1] or m[2], message, flags=re.S)
    message = re.sub(r"(?m)^#{1,6}\s+", "", message)
    message = re.sub(r"(?m)^\s*[-*]\s+", "• ", message)
    return re.sub(r"\n{3,}", "\n\n", message).strip()


def main(argv=None):
    argv = sys.argv[1:] if argv is None else argv
    if len(argv) != 1:
        return 2
    try:
        event = json.loads(argv[0])
    except (TypeError, ValueError):
        return 2
    if not isinstance(event, dict):
        return 2
    if event.get("type") != "agent-turn-complete":
        return 0
    message = event.get("last-assistant-message")
    if not isinstance(message, str) or not message.strip():
        return 0
    try:
        subprocess.run([
            "notify-send", "--app-name=Codex", "--icon=utilities-terminal",
            "--expire-time=20000", "--", "Codex finished",
            html.escape(plain_text(message), quote=False),
        ], check=True, timeout=8)
    except (OSError, subprocess.SubprocessError):
        print("Codex desktop notification could not be delivered", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
