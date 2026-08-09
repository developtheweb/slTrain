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

Design notes (v4, the Sea Update):
  The rails now end at a shoreline. Four vessels join the roster: a
  pirate galleon (flapping Jolly Roger, rubber-duck figurehead), a
  sternwheel steamer (the paddle wheel turns on the same 4-frame
  machinery as the locomotive wheels), a racing sloop, and a harbor tug
  drawn in three-quarter perspective -- it travels diagonally, on the
  angle its art implies, so it appears to grow as it approaches. Sea
  scenes get animated water, hull bob, bow spray, stern wake, and, on
  special request (-d), a dolphin that dives ahead of the ship. At sea,
  -a finds an iceberg, and the iceberg wins.
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
__version__ = "4.0.0"


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

# Alternate liveries for surprise mode
COLOR_THEMES = [
    CHAR_COLORS,
    {'D': ANSI.YELLOW, '_': ANSI.RED, '|': ANSI.RED,
     '=': ANSI.YELLOW, 'O': ANSI.WHITE, 'o': ANSI.WHITE, '~': ANSI.MAGENTA},
    {'D': ANSI.WHITE, '_': ANSI.CYAN, '|': ANSI.BLUE,
     '=': ANSI.CYAN, 'O': ANSI.WHITE, 'o': ANSI.WHITE, '~': ANSI.BLUE},
    {'D': ANSI.MAGENTA, '_': ANSI.GREEN, '|': ANSI.MAGENTA,
     '=': ANSI.CYAN, 'O': ANSI.YELLOW, 'o': ANSI.YELLOW, '~': ANSI.GREEN},
]


def random_theme() -> Dict[str, str]:
    """A one-off livery: each character class gets a random color."""
    pool = [ANSI.RED, ANSI.GREEN, ANSI.YELLOW, ANSI.BLUE,
            ANSI.MAGENTA, ANSI.CYAN, ANSI.WHITE]
    return {ch: random.choice(pool) for ch in CHAR_COLORS}


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



class Vessel:
    """The fleet: side-view sailing craft that ride an animated sea, plus
    the tug and the dolphin, both drawn in three-quarter perspective and
    therefore sailed on the diagonal their artwork implies."""

    # Three-masted pirate galleon, rubber-duck figurehead, gunports
    GALLEON = [
        '                                     |~~~~~~,',
        '                             ` ` ` ` |x_x__/',
        '                   ` ` ` ` `         |     ` ` `',
        '                 |>                  |           ` ` `',
        '             .___|___.           .___|___.             |>',
        '             (   |   \\           (   |   \\             |',
        '            (    |    \\         (    |    \\       .____|____.',
        '           (___________\\       (___________\\      (  ( | )  \\',
        '         `       |                   |           (  (  |  )  \\',
        '            .____|____.         .____|____.     (  (   |   )  \\',
        '       `    (  ( | )  \\         (  ( | )  \\    (__)_________(__\\',
        '     ` /|  (  (  |  )  \\       (  (  |  )  \\           |',
        '      / | (  (   |   )  \\     (  (   |   )  \\         /|    _____',
        '   ` /  |(__)_________(__\\   (__)_________(__\\       / | __|~ ~ ~|',
        '    /   |       /|\\                 /|\\             /  ||  o  o  |',
        '<o)_/___|      / | \\               / | \\           /   || o  o   |',
        '  \\__\\__________________________________________________|________|',
        '    |=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=|',
        '    \\   []    []    []    []    []    []    []    []    []      |',
        '     \\_________S Q U E A K Y____________________________________/',
        '      \\=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_/',
    ]

    # Sternwheel steamer: the wheel spokes rotate via ANIM_SPEC
    STEAMER = [
        '            |==|    |==|        |>',
        '            |  |    |  |        |',
        '          / |  |    |  | \\  .---------.',
        '         /  |  |    |  |  \\ | o  o  o |',
        '          _____________________________________',
        '          | H   H   H   H   H   H   H   H    H |',
        '  |>  _____________________________________________        .=======.',
        '  |   | H   H   H   H   H   H   H   H   H   H    H |      //   |   \\\\',
        '  |____________________________________________________==||----O----||',
        '  | |  H   H   H   H   . T Y P O . H   H   H   H      |   \\\\   |   //',
        "  \\=====================================================/  '======='",
        '   \\___________________________________________________/   ~o~O~o~O~',
    ]

    # Racing sloop for narrow terminals
    SLOOP = [
        '               |>',
        '               | \\',
        '            /| |  \\',
        '           / | | ) \\',
        '          /  | |  ) \\',
        '         /   | |   ) \\',
        '        /    | |    ) \\',
        '        /____| |_______\\ _/',
        '    ____________|____________',
        '   \\   o    o    o        __/',
        '   \\________________________/',
    ]

    # Harbor tug, adapted from a reference piece; drawn in three-quarter
    # perspective, so it travels diagonally toward the viewer
    TUG = [
        '                               $$$$$$$',
        '                    .ooooooo.  $$!!!!!',
        "                  .'.........'.$$!!!!!",
        "                .o'  oooooo   '$$!!!!!      o$$oo.",
        "  ..o$ooo...    $              '!!''!.      $$!!!!!",
        "  $    ..  '''oo$$$$$$$$$$$$$.    '    'oo. $$!!!!!",
        "  !.......      '''..$$ $$ $$$   ..        '$$!!''!",
        "  !!$$$!!!!!!!!oooo......   '''  $$ $$ :o",
        "  !!$$$!!!$$!$$!!!!!!!!!!oo.....     ' ''  o$$o .",
        "  !!!$$!!!!!!!!!!!!!!!!!!!!!!!!!!!!ooooo..      'o  oo..    $",
        "   '!!$$!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!oooooo..  ''   ,$",
        "    '!!$!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!oooo..$$",
        "     !!$!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!$'",
        "     '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$!!!!!!!!!!!!!!!!!!,",
        ' .....$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$.....',
    ]

    # The dolphin (special request). Dives down-left along its drawn angle.
    DOLPHIN = [
        '                                 _',
        '                            _.-~~.)',
        "      _.--~~~~~---....__  .' . .,'",
        "    ,'. . . . . . . . . .~- ._ (",
        '   ( .. .g. . . . . . . . . . .~-._',
        '.~__.-~    ~`. . . . . . . . . . . -.',
        '`----..._      ~-=~~-. . . . . . . . ~-.',
        '          ~-._   `-._ ~=_~~--. . . . . .~.',
        '           | .~-.._  ~--._-.    ~-. . . . ~-.',
        "            \\ .(   ~~--.._~'       `. . . . .~-.                ,",
        "             `._\\         ~~--.._    `. . . . . ~-.    .- .   ,'/",
        ". _ . -~\\        _ ..  _          ~~--.`_. . . . . ~-_     ,-','`  .",
        "          ` ._           ~                ~--. . . . .~=.-'. /. `",
        '    - . -~            -. _ . - ~ - _   - ~     ~--..__~ _,. /   \\  -',
        '            . __ ..                   ~-               ~~_. (  `',
        ' _ _               `-       ..  - .    . - ~ ~ .    \\    ~-` ` `  `.',
        '                                              - .  `  .   \\  \\ `.',
    ]

    # What the -a flag finds at sea
    ICEBERG = [
        '         /\\',
        '        /  \\      /\\',
        '     /\\/    \\    /  \\',
        '    /        \\/\\/    \\',
        '   /                  \\',
        '  /                    \\',
        ' (~~~~~~~~~~~~~~~~~~~~~~)',
    ]

    VESSELS = {
        "galleon": GALLEON,
        "steamer": STEAMER,
        "sloop": SLOOP,
        "tug": TUG,
    }

    SIDE_VIEW = ("galleon", "steamer", "sloop")   # ride the drawn sea
    PERSPECTIVE = ("tug",)                        # travel their drawn angle

    # Per-row 4-frame cycles: flapping colours, turning wheel, churning wake.
    # Same contract as Train.WHEEL_SPEC: every frame matches pattern width.
    ANIM_SPEC = {
        'galleon': [
            (0, '~~~~~~,', ['~~~~~~,', '~~~-~~.', '~~~~-~,', '~-~~~~.']),
            (1, 'x_x__/', ['x_x__/', 'x_x_-.', 'x_x__)', "x_x,-'"]),
            (3, '|>', ['|>', '|=', '|>', '|-']),
            (4, '|>', ['|>', '|-', '|>', '|=']),
        ],
        'steamer': [
            (0, '|>', ['|>', '|=', '|>', '|-']),
            (6, '|>', ['|>', '|-', '|>', '|=']),
            (6, '.=======.', ['.=======.', '.======-.', '.====-==.', '.==-====.']),
            (7, '//   |   \\', ['//   |   \\', '//   /   \\', '//  ---  \\', '//   \\   \\']),
            (9, '\\   |   //', ['\\   |   //', '\\   \\   //', '\\  ---  //', '\\   /   //']),
            (10, "'======='", ["'======='", "'-======'", "'==-===='", "'====-=='"]),
            (11, '~o~O~o~O~', ['~o~O~o~O~', '~~o~O~o~O', 'O~~o~O~o~', '~O~~o~O~o']),
        ],
        'sloop': [
            (0, '|>', ['|>', '|=', '|>', '|-']),
        ],
        'tug': [
        ],
    }

    # Smoke emitters as (dx, dy) from the art's top-left corner
    STACKS = {
        "steamer": [(13, -1), (21, -1)],
        "tug": [(34, -1), (46, 2)],
    }

    # Row of the art that sits on the water surface
    WATERLINE = {
        "galleon": 20,
        "steamer": 11,
        "sloop": 10,
        "tug": 14,
    }

    WHISTLE = {
        "galleon": "YARRR!",
        "steamer": "HOOOONK!",
        "sloop": "ding! ding!",
        "tug": "TOOOOT!",
    }

    # Per-vessel liveries (character-class colouring, like CHAR_COLORS)
    COLORS = {
        "galleon": {'(': ANSI.WHITE, ')': ANSI.WHITE, '\\': ANSI.WHITE,
                    '.': ANSI.WHITE, '`': ANSI.WHITE, 'x': ANSI.WHITE,
                    '~': ANSI.WHITE, '|': ANSI.YELLOW, '_': ANSI.YELLOW,
                    '/': ANSI.YELLOW, '<': ANSI.YELLOW, 'o': ANSI.YELLOW,
                    '>': ANSI.RED, '=': ANSI.RED, '-': ANSI.RED,
                    '[': ANSI.YELLOW, ']': ANSI.YELLOW},
        "steamer": {'|': ANSI.WHITE, '_': ANSI.WHITE, 'H': ANSI.WHITE,
                    '.': ANSI.WHITE, "'": ANSI.WHITE, '-': ANSI.WHITE,
                    '=': ANSI.RED, 'O': ANSI.YELLOW, 'o': ANSI.YELLOW,
                    '>': ANSI.RED, '/': ANSI.WHITE, '\\': ANSI.WHITE,
                    '~': ANSI.CYAN},
        "sloop": {'|': ANSI.WHITE, '\\': ANSI.WHITE, '/': ANSI.WHITE,
                  ')': ANSI.WHITE, '_': ANSI.YELLOW, '.': ANSI.WHITE,
                  'o': ANSI.YELLOW, '>': ANSI.RED, '~': ANSI.CYAN},
        "tug": {'$': ANSI.RED, '!': ANSI.YELLOW, 'o': ANSI.WHITE,
                '.': ANSI.WHITE, "'": ANSI.WHITE, ',': ANSI.WHITE,
                ':': ANSI.WHITE},
    }

    @classmethod
    def frames(cls, style):
        """Build the 4-frame animation cycle for a vessel style."""
        base = cls.VESSELS.get(style, cls.GALLEON)
        frames = []
        for k in range(4):
            art = list(base)
            for row, pattern, cycle in cls.ANIM_SPEC.get(style, []):
                art[row] = art[row].replace(pattern, cycle[k])
            frames.append(art)
        return frames


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
        "spray":    {"chars": "oO*'..",  "gravity": 0.18, "drag": 0.96},
        "wake":     {"chars": "oO~-..",  "gravity": 0.0,  "drag": 0.97},
        "bubble":   {"chars": ".oOo..",  "gravity": -0.06, "drag": 0.98},
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

    def emit_spray(self, x: float, y: float):
        """Foam kicked up where a hull (or a dolphin) meets the water."""
        self.items.append({
            "kind": "spray",
            "x": x + random.uniform(-1, 1), "y": y,
            "vx": -random.uniform(0.1, 0.6),
            "vy": -random.uniform(0.2, 0.7),
            "age": 0, "life": random.randint(8, 14),
        })

    def emit_wake(self, x: float, y: float):
        """Churned water trailing off the stern."""
        self.items.append({
            "kind": "wake",
            "x": x, "y": y + random.uniform(0, 0.6),
            "vx": random.uniform(0.3, 0.8),
            "vy": random.uniform(-0.05, 0.1),
            "age": 0, "life": random.randint(10, 16),
        })

    def emit_bubble(self, x: float, y: float):
        """Air escaping a ship that is no longer, strictly, a ship."""
        self.items.append({
            "kind": "bubble",
            "x": x + random.uniform(-1, 1), "y": y,
            "vx": random.uniform(-0.2, 0.2),
            "vy": -random.uniform(0.05, 0.25),
            "age": 0, "life": random.randint(10, 20),
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
            elif p["kind"] == "spray":
                color = ANSI.WHITE if t < 0.4 else ANSI.CYAN
            elif p["kind"] == "bubble":
                color = ANSI.CYAN if t < 0.6 else ANSI.WHITE
            else:  # stardust and wake share a sea-foam fade
                color = ANSI.CYAN if t < 0.5 else ANSI.WHITE
            screen.put(int(round(p["x"])), int(round(p["y"])), ch, color=color)


class SLAnimation:
    """Main animation controller."""

    def __init__(self, train_type: str = "classic", speed: float = 1.0,
                 fly: bool = False, accident: bool = False,
                 cars: int = 0, whistle: bool = False,
                 use_color: bool = True,
                 palette: Optional[Dict[str, str]] = None,
                 dolphin: bool = False):
        self.train_type = train_type
        self.speed = max(0.1, min(speed, 20.0))
        self.fly = fly
        self.accident = accident
        self.whistle = whistle
        self.use_color = use_color
        self.palette = palette or CHAR_COLORS
        self.running = True
        self.resized = False

        self.is_vessel = train_type in Vessel.VESSELS
        self.dolphin = dolphin and self.is_vessel
        if self.is_vessel:
            # Side-view craft sail the animated sea; perspective craft
            # travel the diagonal their artwork implies.
            self.scene = 'persp' if train_type in Vessel.PERSPECTIVE else 'sea'
            self.frames = Vessel.frames(train_type)
            self.stacks = list(Vessel.STACKS.get(train_type, []))
            self.waterline = Vessel.WATERLINE[train_type]
            self.toot_text = Vessel.WHISTLE.get(train_type, 'TOOT! TOOT!')
            self.funnel_dx = self.stacks[0][0] if self.stacks else 10
        else:
            self.scene = 'rail'
            base = Train.TRAINS.get(train_type, Train.CLASSIC)
            self.frames = [Train.couple(f, cars)
                           for f in Train.frames(train_type)]
            self.waterline = 0
            self.toot_text = 'TOOT! TOOT!'
        self.total_w = max(len(r) for r in self.frames[0])
        self.total_h = len(self.frames[0])
        if self.scene == 'rail':
            # If a coal car is taller than the loco, the loco is padded down
            self.funnel_dy = self.total_h - len(base)
            self.funnel_dx = Train.FUNNEL_X.get(train_type, 7)
            self.stacks = [(self.funnel_dx, self.funnel_dy - 1)]
        else:
            self.funnel_dy = 0

        self.smoke_colors, self.rail_color = self._palette()
        self.dolphin_color = (ANSI.gray(251)
                              if self.smoke_colors[0] != ANSI.WHITE
                              else ANSI.CYAN)

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
        """stdout is not a terminal: print one honest craft, no escapes."""
        for line in self.frames[0]:
            print(line.rstrip())
        if self.is_vessel:
            print('~' * self.total_w)

    def run(self):
        """Run the animation."""
        if not sys.stdout.isatty():
            self.print_static()
            return

        sys.stdout.write(ANSI.ALT_SCREEN_ON + ANSI.HIDE_CURSOR)
        sys.stdout.flush()
        try:
            if self.scene == 'sea':
                self._animate_sea()
            else:
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
            elif self.scene == 'persp':
                # Perspective craft descend as they cross: the travel path
                # matches the angle the art was drawn at, so the craft
                # reads as approaching the viewer.
                drop = max(2, self.height // 3)
                y = max(0, (self.height - self.total_h) // 2 - drop // 2) \
                    + int(drop * self._smooth(progress))
            else:
                y = max(1, (self.height - self.total_h) // 2)

            art = self.frames[(frame_i // 2) % len(self.frames)]

            # Emit particles
            if self.fly:
                if frame_i % 2 == 0:
                    particles.emit_stardust(x + self.total_w, y + self.total_h - 2)
            if frame_i % 2 == 0:
                for sx, sy in self.stacks:
                    particles.emit_smoke(x + sx, y + sy)
            particles.step()

            # Whistle as the funnel passes the marks
            if self.whistle and (x + self.funnel_dx) in toot_marks:
                sys.stdout.write(ANSI.BELL)
                toot_until = frame_i + 8

            # Compose the frame: rails, smoke, train, overlays
            screen.clear()
            if not self.fly and self.scene == 'rail':
                screen.put(0, y + self.total_h, '-' * self.width,
                           color=self.rail_color)
            particles.draw(screen)
            for i, line in enumerate(art):
                screen.put(x, y + i, line, charmap=self.palette, opaque=True)
            if frame_i < toot_until:
                screen.put(x + self.funnel_dx + 3, y + self.funnel_dy - 2,
                           self.toot_text, color=ANSI.WHITE)

            sys.stdout.write(screen.frame())
            sys.stdout.flush()

            # The -a flag: the train makes it halfway, and no further.
            # On terminals narrower than the train, crash at the left edge
            # so the wreck stays visible.
            if self.accident and x <= max(0, (self.width - self.total_w) // 2):
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

    def _draw_sea(self, screen: Screen, water_y: int, frame_i: int):
        """Animated sea: a drifting swell pattern on the surface and
        deterministic glints in the depths (no randomness, so the water
        shimmers instead of boiling)."""
        pat = '~~~~ ~~~ ~~~~~ ~~ ~~~ ~~~~ '
        off = (frame_i // 2) % len(pat)
        row = (pat * (self.width // len(pat) + 2))[off:off + self.width]
        screen.put(0, water_y, row, color=ANSI.CYAN)
        deep = self.rail_color or ANSI.CYAN
        for gy in range(water_y + 1, self.height):
            step = 11 + (gy * 7) % 9
            phase = (frame_i // 3 + gy * 5) % step
            for gx in range(phase, self.width, step):
                screen.put(gx, gy, '~' if (gx + gy) % 3 else '.', color=deep)

    def _animate_sea(self):
        """A sea voyage: animated water, a bobbing hull, spray and wake,
        optionally a dolphin, and -- with -a -- an iceberg."""
        screen = Screen(self.width, self.height, self.use_color)
        particles = Particles(self.smoke_colors)
        frame_dt = 0.05 / self.speed
        total_frames = self.width + self.total_w + 24
        toot_until = -1
        toot_marks = {int(self.width * 0.66), int(self.width * 0.33)}
        next_tick = time.monotonic()
        frame_i = 0

        # The sea rises to meet tall ships; it pans down slightly across
        # the crossing so the whole scene leans toward the viewer.
        sea0 = max(1, min(max(int(self.height * 0.60), self.waterline),
                          self.height - 3))
        pan = max(0, min(2, (self.height - 3) - sea0))
        ice_x = max(2, self.width // 6)
        dolphin_at = self.width // 4 if self.dolphin else -1
        dol_h = len(Vessel.DOLPHIN)

        while self.running and frame_i < total_frames:
            if self.resized:
                self.resized = False
                self.update_terminal_size()
                screen = Screen(self.width, self.height, self.use_color)
                sea0 = max(1, min(max(int(self.height * 0.60),
                                      self.waterline), self.height - 3))
                pan = max(0, min(2, (self.height - 3) - sea0))

            x = self.width - frame_i
            progress = frame_i / total_frames
            water_y = sea0 + int(pan * self._smooth(progress))
            if self.fly:
                # The Flying Dutchman: the sea stays low, the ship does not
                water_y = self.height - 3
                floor_y = max(1, water_y - self.total_h - 1)
                y = int(2 + (floor_y - 2) * (1 - self._smooth(progress))
                        + 1.5 * math.sin(progress * 7))
                y = max(1, min(floor_y, y))
            else:
                bob = int(round(math.sin(frame_i * 0.15) * 0.9))
                y = water_y - self.waterline + bob

            art = self.frames[(frame_i // 2) % len(self.frames)]

            # Spray at the bow, wake off the stern, smoke from the stacks
            if self.fly:
                if frame_i % 2 == 0:
                    particles.emit_stardust(x + self.total_w,
                                            y + self.total_h - 2)
            else:
                if frame_i % 2 == 0:
                    particles.emit_spray(x + 4, water_y)
                if frame_i % 3 == 0:
                    particles.emit_wake(x + self.total_w - 3, water_y)
            if frame_i % 2 == 0:
                for sx, sy in self.stacks:
                    particles.emit_smoke(x + sx, y + sy)
            particles.step()

            if self.whistle and (x + 10) in toot_marks:
                sys.stdout.write(ANSI.BELL)
                toot_until = frame_i + 8

            screen.clear()
            self._draw_sea(screen, water_y, frame_i)

            # The dolphin dives ahead of the ship, on its drawn angle
            if dolphin_at >= 0 and frame_i >= dolphin_at:
                t = frame_i - dolphin_at
                dy = water_y - dol_h + 2 + t // 2
                dx = int(self.width * 0.45) - 40 - t
                if dy >= water_y:
                    dolphin_at = -1     # fully sounded; gone
                else:
                    for i, line in enumerate(Vessel.DOLPHIN):
                        if dy + i < water_y:
                            screen.put(dx, dy + i, line,
                                       color=self.dolphin_color)
                    i0 = water_y - dy   # art row crossing the surface
                    particles.emit_spray(dx + max(2, 2 * (dol_h - i0)),
                                         water_y)

            particles.draw(screen)

            if self.accident and not self.fly:
                by = water_y - len(Vessel.ICEBERG) + 1
                for i, line in enumerate(Vessel.ICEBERG):
                    screen.put(ice_x, by + i, line, color=ANSI.WHITE)

            for i, line in enumerate(art):
                screen.put(x, y + i, line, charmap=self.palette, opaque=True)
            if frame_i < toot_until:
                screen.put(x + 12, max(0, y - 2), self.toot_text,
                           color=ANSI.WHITE)

            sys.stdout.write(screen.frame())
            sys.stdout.flush()

            # The -a flag, at sea: the iceberg wins. It always wins.
            if self.accident and not self.fly and x <= ice_x + 16:
                self._sink(screen, particles, x, y, art, water_y, ice_x)
                return

            next_tick += frame_dt
            delay = next_tick - time.monotonic()
            if delay > 0:
                time.sleep(delay)
            else:
                next_tick = time.monotonic()
            frame_i += 1

    def _sink(self, screen: Screen, particles: Particles,
              x: int, y: int, art: List[str], water_y: int, ice_x: int):
        """Iceberg finale: a crunch, a shudder, and a dignified descent."""
        depth = 0
        frames = 30 + (self.total_h + 2) * 3
        for f in range(frames):
            if not self.running:
                return
            if f < 12:
                for _ in range(4):
                    particles.emit_spray(x + random.randint(0, 8),
                                         water_y - random.randint(0, 2))
            if f >= 14:
                depth = (f - 14) // 3
                if f % 2 == 0:
                    particles.emit_bubble(
                        x + random.randint(4, max(5, self.total_w - 4)),
                        water_y + 1)
            particles.step()

            shake = random.randint(-1, 1) if f < 12 else 0

            screen.clear()
            self._draw_sea(screen, water_y, f)
            by = water_y - len(Vessel.ICEBERG) + 1
            for i, line in enumerate(Vessel.ICEBERG):
                screen.put(ice_x, by + i, line, color=ANSI.WHITE)
            particles.draw(screen)
            sy = y + depth
            for i, line in enumerate(art):
                if sy + i <= water_y:   # what's under stays under
                    screen.put(x + shake, sy + i, line,
                               charmap=self.palette, opaque=True)
            if f < 34 and (f // 3) % 2 == 0:
                msg = 'C R U N C H !' if f < 14 else 'B L U B   B L U B'
                color = ANSI.RED if f < 14 else ANSI.CYAN
                screen.put(max(2, x + 6), max(1, water_y - self.total_h - 1),
                           msg, color=color)

            sys.stdout.write(screen.frame())
            sys.stdout.flush()
            time.sleep(0.06 / self.speed)

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
            if self.scene == 'rail':
                screen.put(0, y + self.total_h, '-' * self.width,
                           color=self.rail_color)
            particles.draw(screen)
            for i, line in enumerate(art):
                screen.put(x + dx, y + i + dy, line,
                           charmap=self.palette, opaque=True)
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
    parser.add_argument('-t', '--type',
                        choices=sorted(Train.TRAINS) + sorted(Vessel.VESSELS),
                        help='locomotive or vessel type (overrides -l/-c)')
    parser.add_argument('-n', '--cars', type=int, default=0, metavar='N',
                        help='number of coal cars to pull (default: 0; '
                             'rail only -- coal cars do not float)')
    parser.add_argument('-d', '--dolphin', action='store_true',
                        help='a dolphin joins the voyage (implies a vessel)')
    parser.add_argument('-w', '--whistle', action='store_true',
                        help='sound the whistle as the train passes')
    parser.add_argument('-s', '--speed', type=float, default=1.0,
                        help='animation speed multiplier, '
                             'clamped to 0.1-20 (default: 1.0)')
    parser.add_argument('--no-color', action='store_true',
                        help='disable colors (NO_COLOR is also honored)')
    parser.add_argument('-v', '--version', action='version',
                        version=f'sl version {__version__}')

    args = parser.parse_args()

    # Determine what rolls out (or sets sail)
    if args.type:
        craft = args.type
    elif args.C51:
        craft = "c51"
    elif args.long:
        craft = "d51"
    else:
        craft = "classic"

    # A dolphin will not follow a train. Requesting one books sea passage.
    if args.dolphin and craft not in Vessel.VESSELS:
        craft = random.choice(Vessel.SIDE_VIEW)

    cars = max(0, min(args.cars, 8))
    if args.long and not args.type and args.cars == 0:
        cars = 2  # --long should actually be long (unless -t overrides it)
    if craft in Vessel.VESSELS:
        cars = 0  # coal cars do not float

    use_color = (not args.no_color
                 and 'NO_COLOR' not in os.environ
                 and sys.stdout.isatty())

    # Surprise mode: a bare `sl` -- the classic mistyped `ls` -- rolls the
    # dice on everything, so no two typos look alike. Any flag at all
    # switches back to fully deterministic behavior.
    palette = None
    speed = args.speed
    fly, accident, whistle = args.fly, args.accident, args.whistle
    dolphin = args.dolphin
    if len(sys.argv) == 1:
        if random.random() < 0.35:      # some typos are nautical
            craft = random.choice(sorted(Vessel.VESSELS))
            dolphin = (craft in Vessel.SIDE_VIEW
                       and random.random() < 0.20)
        else:
            craft = random.choice(list(Train.TRAINS))
            cars = random.choice([0, 0, 0, 1, 2, 2, 3, 4, 8])
            palette = random.choice(COLOR_THEMES + [random_theme()])
        speed = random.uniform(0.8, 1.5)
        whistle = random.random() < 0.25
        roll = random.random()
        accident = roll < 0.05          # rare: the typo ends in tragedy
        fly = 0.05 <= roll < 0.15       # rare: the typo takes flight

    # Vessels sail under their own colors, surprise or not
    if craft in Vessel.VESSELS:
        palette = Vessel.COLORS.get(craft, CHAR_COLORS)

    # Run animation
    animation = SLAnimation(
        train_type=craft,
        speed=speed,
        fly=fly,
        accident=accident,
        cars=cars,
        whistle=whistle,
        use_color=use_color,
        palette=palette,
        dolphin=dolphin,
    )

    animation.run()


if __name__ == "__main__":
    main()
