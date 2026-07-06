#!/usr/bin/env python3
"""
sl - Steam Locomotive
A joke command that displays an animated train when you type 'sl' instead of 'ls'
Author: Reverend Steven Milanese
License: MIT

Design notes (v3):
  The entire point of sl is maximal output for minimal input -- two
  mistyped letters buy you a locomotive. v3 keeps the original contract
  (one file, stdlib only, same flags, Ctrl+C still works) and upgrades
  the show: a flicker-free double-buffered renderer on the alternate
  screen, wheels that actually turn, smoke that drifts and dissipates,
  coal cars, a whistle, and a crash that earns the -a flag. When stdout
  is not a terminal, a static train is printed instead of escape codes,
  so `sl | cat` stays a train and not a mess.
"""

import argparse
import math
import os
import random
import signal
import sys
import time
from typing import Dict, List, Optional

# Version
__version__ = "3.0.0"


# ANSI escape codes for colors and cursor control
class ANSI:
    # Colors
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    MAGENTA = '\033[95m'
    CYAN = '\033[96m'
    WHITE = '\033[97m'
    RESET = '\033[0m'

    # Cursor and screen control
    HIDE_CURSOR = '\033[?25l'
    SHOW_CURSOR = '\033[?25h'
    ALT_SCREEN_ON = '\033[?1049h'
    ALT_SCREEN_OFF = '\033[?1049l'
    BELL = '\a'

    @staticmethod
    def gray(level: int) -> str:
        """256-color grayscale (232 = near black .. 255 = near white)."""
        return f'\033[38;5;{level}m'

    @staticmethod
    def move_cursor(x: int, y: int) -> str:
        """Move cursor to position (1-based)."""
        return f'\033[{y};{x}H'


# Character-based coloring of the train art (original v2 palette)
CHAR_COLORS = {
    'D': ANSI.RED,
    '_': ANSI.YELLOW,
    '|': ANSI.BLUE,
    '=': ANSI.GREEN,
    'O': ANSI.WHITE,
    'o': ANSI.WHITE,
    '~': ANSI.CYAN,
}


class Train:
    """The ASCII art trains, their animated wheel frames, and rolling stock."""

    # Classic steam locomotive
    CLASSIC = [
        "      ====        ________                ___________",
        "  _D _|  |_______/        \\__I_I_____===__|_________|",
        "   |(_)---  |   H\\________/ |   |        =|___ ___|  ",
        "   /     |  |   H  |  |     |   |         ||_| |_||  ",
        "  |      |  |   H  |__--------------------| [___] |  ",
        "  | ________|___H__/__|_____/[][]~\\_______|       |  ",
        "  |/ |   |-----------I_____I [][] []  D   |=======|__",
        "__/ =| o |=-~~\\  /~~\\  /~~\\  /~~\\ ____Y___________|__",
        " |/-=|___|=    ||    ||    ||    |_____/~\\___/       ",
        "  \\_/      \\O=====O=====O=====O_/      \\_/           "
    ]

    # Small locomotive for narrow terminals
    SMALL = [
        "     ++      +------ ",
        "     ||      |+-+ |  ",
        "   /---------|| | |  ",
        "  + ========  +-+ |  ",
        " _|--O========O~\\-+  ",
        "//// \\_/      \\_/    "
    ]

    # D51 locomotive (Japanese style)
    D51 = [
        "      ====        ________                ___________ ",
        "  _D _|  |_______/        \\__I_I_____===__|_________|",
        "   |(_)---  |   H\\________/ |   |        =|___ ___|  ",
        "   /     |  |   H  |  |     |   |         ||_| |_||  ",
        "  |      |  |   H  |__--------------------| [___] |  ",
        "  | ________|___H__/__|_____/[][]~\\_______|       |  ",
        "  |/ |   |-----------I_____I [][] []  D   |=======|__",
        "__/ =| o |=-O=====O=====O=====O \\ ____Y___________|__",
        " |/-=|___|=    ||    ||    ||    |_____/~\\___/       ",
        "  \\_/      \\__/  \\__/  \\__/  \\__/      \\_/           "
    ]

    # C51 locomotive
    C51 = [
        "        ___                                            ",
        "       _|_|_  _     __       __             ___________",
        "    D__/   \\_(_)___|  |__H__|  |_____I_Ii_()|_________|",
        "     | `---'   |:: `--'  H  `--'         |  |___ ___|  ",
        "    +|~~~~~~~~++::~~~~~~~H~~+=====+~~~~~~|~~||_| |_||  ",
        "    ||        | ::       H  +=====+      |  |::  ...|  ",
        "|    | _______|_::-----------------[][]-----|       |  ",
        "| /~~ ||   |-----/~~~~\\  /[I_____I][][] --|||_______|__",
        "------'|oOo|===[]-     ||      ||      |  ||=======_|__",
        "/~\\____|___|/~\\_|   O=======O=======O  |__|\\       /   ",
        "\\_/         \\_/  \\____/  \\____/  \\____/      \\_____/    "
    ]

    # Coal tender, adapted from Toyoda Masashi's original sl
    COAL_CAR = [
        "                              ",
        "    _________________         ",
        "   _|                \\_____A  ",
        " =|                        |  ",
        " -|                        |  ",
        "__|________________________|_ ",
        "|__________________________|_ ",
        "   |_D__D__D_|  |_D__D__D_|   ",
        "    \\_/   \\_/    \\_/   \\_/    ",
    ]

    TRAINS = {
        "classic": CLASSIC,
        "small": SMALL,
        "d51": D51,
        "c51": C51,
    }

    # Wheel animation: (row index, pattern, 4-frame cycle). Each cycle entry
    # must be the same width as the pattern it replaces.
    WHEEL_SPEC = {
        "classic": [
            (8, "||", ["||", "//", "--", "\\\\"]),
            (9, "=====", ["=====", "-====", "==-==", "===-="]),
        ],
        "d51": [
            (7, "=====", ["=====", "-====", "==-==", "===-="]),
            (8, "||", ["||", "//", "--", "\\\\"]),
        ],
        "c51": [
            (9, "=======", ["=======", "-======", "===-===", "=====-="]),
        ],
        "small": [
            (4, "========", ["========", "-=======", "===-====", "=====-=="]),
        ],
    }

    # Column of the smokestack, relative to the left edge of the art
    FUNNEL_X = {"classic": 7, "d51": 7, "c51": 9, "small": 5}

    @classmethod
    def frames(cls, style: str) -> List[List[str]]:
        """Build the wheel-animation frames for a train style."""
        base = cls.TRAINS.get(style, cls.CLASSIC)
        frames = []
        for k in range(4):
            art = list(base)
            for row, pattern, cycle in cls.WHEEL_SPEC.get(style, []):
                art[row] = art[row].replace(pattern, cycle[k])
            frames.append(art)
        return frames

    @classmethod
    def couple(cls, train_art: List[str], cars: int) -> List[str]:
        """Attach coal cars behind the locomotive, bottom-aligned."""
        parts = [train_art] + [cls.COAL_CAR] * max(0, cars)
        height = max(len(p) for p in parts)
        widths = [max(len(r) for r in p) for p in parts]
        rows = []
        for i in range(height):
            row = ""
            for part, width in zip(parts, widths):
                pad = height - len(part)
                src = part[i - pad] if i >= pad else ""
                row += src.ljust(width)
            rows.append(row)
        return rows


class Screen:
    """Double-buffered frame composer: draw everything into an off-screen
    cell buffer, then emit the whole frame as one write. No per-frame
    clear-screen means no flicker."""

    def __init__(self, width: int, height: int, use_color: bool):
        self.w = width
        self.h = height
        self.use_color = use_color
        self.chars: List[List[str]] = []
        self.colors: List[List[Optional[str]]] = []
        self.clear()

    def clear(self):
        self.chars = [[' '] * self.w for _ in range(self.h)]
        self.colors = [[None] * self.w for _ in range(self.h)]

    def put(self, x: int, y: int, text: str,
            color: Optional[str] = None,
            charmap: Optional[Dict[str, str]] = None,
            opaque: bool = False):
        """Draw text at (x, y), clipping to the screen. Spaces are
        transparent unless opaque, in which case interior spaces (between
        the first and last visible character) overwrite what's below."""
        if not (0 <= y < self.h) or not text:
            return
        start = end = 0
        if opaque:
            body = text.rstrip()
            start = len(body) - len(body.lstrip())
            end = len(body)
        row, crow = self.chars[y], self.colors[y]
        for i, ch in enumerate(text):
            if ch == ' ' and not (opaque and start <= i < end):
                continue
            cx = x + i
            if 0 <= cx < self.w:
                row[cx] = ch
                if charmap and ch in charmap:
                    crow[cx] = charmap[ch]
                else:
                    crow[cx] = color

    def frame(self) -> str:
        """Serialize the buffer to a single escape-code string."""
        parts = [ANSI.RESET] if self.use_color else []
        current = None
        for y in range(self.h):
            parts.append(ANSI.move_cursor(1, y + 1))
            row, crow = self.chars[y], self.colors[y]
            for x in range(self.w):
                if self.use_color:
                    color = crow[x]
                    if color != current:
                        parts.append(color if color is not None else ANSI.RESET)
                        current = color
                parts.append(row[x])
        if self.use_color and current is not None:
            parts.append(ANSI.RESET)
        return ''.join(parts)


class Particles:
    """Tiny particle system for smoke, crash sparks, and stardust."""

    KINDS = {
        # chars are indexed by age; drift/gravity give each kind its motion
        "smoke":    {"chars": "@@Oo*..", "gravity": 0.0,  "drag": 0.98},
        "spark":    {"chars": "@**+x..", "gravity": 0.12, "drag": 1.0},
        "stardust": {"chars": "**++...", "gravity": 0.0,  "drag": 0.99},
    }

    def __init__(self, smoke_colors: List[str]):
        self.items: List[dict] = []
        self.smoke_colors = smoke_colors

    def emit_smoke(self, x: float, y: float):
        self.items.append({
            "kind": "smoke",
            "x": x + random.uniform(-1, 1), "y": y,
            "vx": random.uniform(0.4, 0.9),   # smoke trails behind the train
            "vy": -random.uniform(0.2, 0.45),
            "age": 0, "life": random.randint(14, 22),
        })

    def emit_spark(self, x: float, y: float):
        angle = random.uniform(0, 2 * math.pi)
        speed = random.uniform(0.4, 1.8)
        self.items.append({
            "kind": "spark",
            "x": x, "y": y,
            "vx": math.cos(angle) * speed,
            "vy": math.sin(angle) * speed * 0.6 - 0.4,
            "age": 0, "life": random.randint(10, 18),
        })

    def emit_stardust(self, x: float, y: float):
        self.items.append({
            "kind": "stardust",
            "x": x, "y": y + random.uniform(-1, 1),
            "vx": random.uniform(0.5, 1.1),
            "vy": random.uniform(-0.15, 0.15),
            "age": 0, "life": random.randint(8, 14),
        })

    def step(self):
        alive = []
        for p in self.items:
            spec = self.KINDS[p["kind"]]
            p["x"] += p["vx"]
            p["y"] += p["vy"]
            p["vx"] *= spec["drag"]
            p["vy"] += spec["gravity"]
            p["age"] += 1
            if p["age"] < p["life"]:
                alive.append(p)
        self.items = alive

    def draw(self, screen: Screen):
        for p in self.items:
            spec = self.KINDS[p["kind"]]
            t = p["age"] / p["life"]
            chars = spec["chars"]
            ch = chars[min(int(t * len(chars)), len(chars) - 1)]
            if p["kind"] == "smoke":
                idx = min(int(t * len(self.smoke_colors)), len(self.smoke_colors) - 1)
                color = self.smoke_colors[idx]
            elif p["kind"] == "spark":
                color = ANSI.WHITE if t < 0.3 else (ANSI.YELLOW if t < 0.6 else ANSI.RED)
            else:
                color = ANSI.CYAN if t < 0.5 else ANSI.WHITE
            screen.put(int(round(p["x"])), int(round(p["y"])), ch, color=color)


class SLAnimation:
    """Main animation controller."""

    def __init__(self, train_type: str = "classic", speed: float = 1.0,
                 fly: bool = False, accident: bool = False,
                 cars: int = 0, whistle: bool = False,
                 use_color: bool = True):
        self.train_type = train_type
        self.speed = max(0.1, min(speed, 20.0))
        self.fly = fly
        self.accident = accident
        self.whistle = whistle
        self.use_color = use_color
        self.running = True
        self.resized = False

        base = Train.TRAINS.get(train_type, Train.CLASSIC)
        self.frames = [Train.couple(f, cars) for f in Train.frames(train_type)]
        self.total_w = max(len(r) for r in self.frames[0])
        self.total_h = len(self.frames[0])
        # If a coal car is taller than the loco, the loco is padded down
        self.funnel_dy = self.total_h - len(base)
        self.funnel_dx = Train.FUNNEL_X.get(train_type, 7)

        self.smoke_colors, self.rail_color = self._palette()

        self.update_terminal_size()
        signal.signal(signal.SIGINT, self._handle_interrupt)
        if hasattr(signal, 'SIGWINCH'):
            signal.signal(signal.SIGWINCH, self._handle_resize)

    def _palette(self):
        """Grayscale smoke on 256-color terminals, plain white elsewhere."""
        term = os.environ.get('TERM', '')
        if '256' in term or os.environ.get('COLORTERM'):
            smoke = [ANSI.gray(g) for g in (255, 251, 248, 245, 242)]
            rail = ANSI.gray(240)
        else:
            smoke = [ANSI.WHITE] * 5
            rail = None
        return smoke, rail

    def update_terminal_size(self):
        """Update terminal dimensions."""
        try:
            size = os.get_terminal_size()
            # Some ptys report 0x0; a degenerate size gets the default
            self.width = size.columns if size.columns > 0 else 80
            self.height = size.lines if size.lines > 0 else 24
        except OSError:
            self.width = 80
            self.height = 24

    def _handle_resize(self, signum, frame):
        """Handle terminal resize (applied at the next frame)."""
        self.resized = True

    def _handle_interrupt(self, signum, frame):
        """Handle Ctrl+C gracefully."""
        self.running = False

    @staticmethod
    def _smooth(p: float) -> float:
        """Smoothstep easing for the flight path."""
        return p * p * (3 - 2 * p)

    def print_static(self):
        """stdout is not a terminal: print one honest train, no escapes."""
        for line in self.frames[0]:
            print(line.rstrip())

    def run(self):
        """Run the animation."""
        if not sys.stdout.isatty():
            self.print_static()
            return

        sys.stdout.write(ANSI.ALT_SCREEN_ON + ANSI.HIDE_CURSOR)
        sys.stdout.flush()
        try:
            self._animate()
        finally:
            # The alternate screen restores whatever was there before
            sys.stdout.write(ANSI.SHOW_CURSOR + ANSI.ALT_SCREEN_OFF)
            sys.stdout.flush()

    def _animate(self):
        screen = Screen(self.width, self.height, self.use_color)
        particles = Particles(self.smoke_colors)
        frame_dt = 0.05 / self.speed
        total_frames = self.width + self.total_w + 12
        toot_until = -1
        toot_marks = {int(self.width * 0.66), int(self.width * 0.33)}
        next_tick = time.monotonic()
        frame_i = 0

        while self.running and frame_i < total_frames:
            if self.resized:
                self.resized = False
                self.update_terminal_size()
                screen = Screen(self.width, self.height, self.use_color)

            x = self.width - frame_i
            progress = frame_i / total_frames
            if self.fly:
                floor_y = max(1, self.height - self.total_h - 2)
                y = int(2 + (floor_y - 2) * (1 - self._smooth(progress))
                        + 1.5 * math.sin(progress * 7))
                y = max(1, min(self.height - self.total_h - 1, y))
            else:
                y = max(1, (self.height - self.total_h) // 2)

            art = self.frames[(frame_i // 2) % len(self.frames)]

            # Emit particles
            if self.fly:
                if frame_i % 2 == 0:
                    particles.emit_stardust(x + self.total_w, y + self.total_h - 2)
            if frame_i % 2 == 0:
                particles.emit_smoke(x + self.funnel_dx, y + self.funnel_dy - 1)
            particles.step()

            # Whistle as the funnel passes the marks
            if self.whistle and (x + self.funnel_dx) in toot_marks:
                sys.stdout.write(ANSI.BELL)
                toot_until = frame_i + 8

            # Compose the frame: rails, smoke, train, overlays
            screen.clear()
            if not self.fly:
                screen.put(0, y + self.total_h, '-' * self.width,
                           color=self.rail_color)
            particles.draw(screen)
            for i, line in enumerate(art):
                screen.put(x, y + i, line, charmap=CHAR_COLORS, opaque=True)
            if frame_i < toot_until:
                screen.put(x + self.funnel_dx + 3, y + self.funnel_dy - 2,
                           'TOOT! TOOT!', color=ANSI.WHITE)

            sys.stdout.write(screen.frame())
            sys.stdout.flush()

            # The -a flag: the train makes it halfway, and no further
            if self.accident and x <= (self.width - self.total_w) // 2:
                self._crash(screen, particles, x, y, art)
                return

            # Monotonic pacing: no drift from render time
            next_tick += frame_dt
            delay = next_tick - time.monotonic()
            if delay > 0:
                time.sleep(delay)
            else:
                next_tick = time.monotonic()
            frame_i += 1

            if x + self.total_w < 0:
                break

    def _crash(self, screen: Screen, particles: Particles,
               x: int, y: int, art: List[str]):
        """Accident mode finale: shake, sparks, and a proper BOOM."""
        messages = ['C R A S H !', 'B O O M !']
        front_y = y + self.total_h // 2
        for f in range(55):
            if not self.running:
                return
            if f < 14:
                for _ in range(5):
                    particles.emit_spark(x + random.randint(0, 8),
                                         front_y + random.randint(-2, 2))
            elif f < 40 and f % 3 == 0:
                particles.emit_smoke(x + random.randint(0, 6), front_y - 2)
            particles.step()

            shake = f < 20
            dx = random.randint(-1, 1) if shake else 0
            dy = random.randint(-1, 0) if shake else 0

            screen.clear()
            screen.put(0, y + self.total_h, '-' * self.width,
                       color=self.rail_color)
            particles.draw(screen)
            for i, line in enumerate(art):
                screen.put(x + dx, y + i + dy, line,
                           charmap=CHAR_COLORS, opaque=True)
            if f < 32 and (f // 3) % 2 == 0:
                color = ANSI.RED if (f // 6) % 2 == 0 else ANSI.YELLOW
                screen.put(x + 6, y - 2, messages[(f // 6) % 2], color=color)

            sys.stdout.write(screen.frame())
            sys.stdout.flush()
            time.sleep(0.06 / self.speed)


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        prog='sl',
        description='sl - Display animated steam locomotive',
        epilog='A joke command for when you type sl instead of ls'
    )

    parser.add_argument('-a', '--accident', action='store_true',
                        help='an accident occurs')
    parser.add_argument('-F', '--fly', action='store_true',
                        help='make the train fly')
    parser.add_argument('-l', '--long', action='store_true',
                        help='use a longer train (D51 pulling coal cars)')
    parser.add_argument('-c', '--C51', action='store_true',
                        help='use C51 train type')
    parser.add_argument('-t', '--type', choices=sorted(Train.TRAINS),
                        help='locomotive type (overrides -l/-c)')
    parser.add_argument('-n', '--cars', type=int, default=0, metavar='N',
                        help='number of coal cars to pull (default: 0)')
    parser.add_argument('-w', '--whistle', action='store_true',
                        help='sound the whistle as the train passes')
    parser.add_argument('-s', '--speed', type=float, default=1.0,
                        help='animation speed multiplier (default: 1.0)')
    parser.add_argument('--no-color', action='store_true',
                        help='disable colors (NO_COLOR is also honored)')
    parser.add_argument('-v', '--version', action='version',
                        version=f'sl version {__version__}')

    args = parser.parse_args()

    # Determine train type
    if args.type:
        train_type = args.type
    elif args.C51:
        train_type = "c51"
    elif args.long:
        train_type = "d51"
    else:
        train_type = "classic"

    cars = max(0, min(args.cars, 8))
    if args.long and args.cars == 0:
        cars = 2  # --long should actually be long

    use_color = (not args.no_color
                 and 'NO_COLOR' not in os.environ
                 and sys.stdout.isatty())

    # Run animation
    animation = SLAnimation(
        train_type=train_type,
        speed=args.speed,
        fly=args.fly,
        accident=args.accident,
        cars=cars,
        whistle=args.whistle,
        use_color=use_color,
    )

    animation.run()


if __name__ == "__main__":
    main()
