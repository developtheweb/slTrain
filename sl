#!/usr/bin/env python3
"""
sl - Steam Locomotive
A joke command that displays an animated train when you type 'sl' instead of 'ls'
Author: Reverend Steven Milanese
License: MIT
"""

import os
import sys
import time
import random
import signal
import argparse
from typing import List, Tuple

# Version
__version__ = "2.0.0"

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
    
    # Cursor control
    HIDE_CURSOR = '\033[?25l'
    SHOW_CURSOR = '\033[?25h'
    CLEAR_SCREEN = '\033[2J\033[H'
    CLEAR_LINE = '\033[2K'
    
    @staticmethod
    def move_cursor(x: int, y: int) -> str:
        """Move cursor to position."""
        return f'\033[{y};{x}H'


class Train:
    """Represents the ASCII art train with different styles."""
    
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
    
    # Small locomotive for faster animation
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
    
    @staticmethod
    def get_train(style: str = "classic") -> List[str]:
        """Get train ASCII art by style."""
        trains = {
            "classic": Train.CLASSIC,
            "small": Train.SMALL,
            "D51": Train.D51,
            "C51": Train.C51
        }
        return trains.get(style, Train.CLASSIC)


class SmokeGenerator:
    """Generates dynamic smoke patterns."""
    
    SMOKE_CHARS = ['@', '*', 'o', 'O', '.', '\'', '"']
    
    @staticmethod
    def generate(length: int, density: float = 0.4) -> str:
        """Generate a smoke pattern."""
        smoke = []
        for _ in range(length):
            if random.random() < density:
                smoke.append(random.choice(SmokeGenerator.SMOKE_CHARS))
            else:
                smoke.append(' ')
        return ''.join(smoke)
    
    @staticmethod
    def get_smoke_lines(width: int, height: int = 4) -> List[str]:
        """Generate multiple lines of smoke."""
        lines = []
        for i in range(height):
            density = 0.4 - (i * 0.1)  # Decrease density as smoke rises
            lines.append(SmokeGenerator.generate(width, density))
        return lines


class SLAnimation:
    """Main animation controller."""
    
    def __init__(self, train_type: str = "classic", speed: float = 1.0, 
                 fly: bool = False, accident: bool = False):
        self.train_type = train_type
        self.speed = speed
        self.fly = fly
        self.accident = accident
        self.running = True
        
        # Get terminal size
        self.update_terminal_size()
        
        # Setup signal handler for window resize
        signal.signal(signal.SIGWINCH, self._handle_resize)
        signal.signal(signal.SIGINT, self._handle_interrupt)
    
    def update_terminal_size(self):
        """Update terminal dimensions."""
        try:
            size = os.get_terminal_size()
            self.width = size.columns
            self.height = size.lines
        except:
            self.width = 80
            self.height = 24
    
    def _handle_resize(self, signum, frame):
        """Handle terminal resize."""
        self.update_terminal_size()
    
    def _handle_interrupt(self, signum, frame):
        """Handle Ctrl+C gracefully."""
        self.running = False
    
    def clear_screen(self):
        """Clear the terminal screen."""
        sys.stdout.write(ANSI.CLEAR_SCREEN)
        sys.stdout.flush()
    
    def run(self):
        """Run the animation."""
        # Hide cursor
        sys.stdout.write(ANSI.HIDE_CURSOR)
        sys.stdout.flush()
        
        try:
            train_lines = Train.get_train(self.train_type)
            train_height = len(train_lines)
            train_width = max(len(line) for line in train_lines)
            
            # Calculate vertical position
            if self.fly:
                y_positions = self._calculate_fly_path(train_height)
            else:
                y_position = (self.height - train_height) // 2
                y_positions = [y_position] * (self.width + train_width + 10)
            
            # Animation loop
            frame = 0
            while self.running and frame < len(y_positions):
                self.clear_screen()
                
                # Calculate horizontal position (right to left)
                x_position = self.width - frame
                y_position = y_positions[frame]
                
                # Add smoke above train
                if not self.fly:
                    smoke_lines = SmokeGenerator.get_smoke_lines(train_width + 20, 4)
                    for i, smoke in enumerate(smoke_lines):
                        smoke_y = y_position - len(smoke_lines) + i
                        if smoke_y > 0:
                            sys.stdout.write(ANSI.move_cursor(max(1, x_position - 10), smoke_y))
                            sys.stdout.write(ANSI.WHITE + smoke + ANSI.RESET)
                
                # Draw train
                for i, line in enumerate(train_lines):
                    if 0 < y_position + i <= self.height:
                        # Calculate visible portion of line
                        if x_position < 1:
                            # Train is partially off-screen (left side)
                            start = abs(x_position) + 1
                            if start < len(line):
                                visible_line = line[start:]
                                sys.stdout.write(ANSI.move_cursor(1, y_position + i))
                                sys.stdout.write(self._colorize_line(visible_line))
                        elif x_position + len(line) > self.width:
                            # Train is partially off-screen (right side)
                            visible_line = line[:self.width - x_position]
                            sys.stdout.write(ANSI.move_cursor(x_position, y_position + i))
                            sys.stdout.write(self._colorize_line(visible_line))
                        else:
                            # Train is fully visible
                            sys.stdout.write(ANSI.move_cursor(x_position, y_position + i))
                            sys.stdout.write(self._colorize_line(line))
                
                # Accident mode - show collision
                if self.accident and x_position < self.width // 2:
                    self._show_accident(x_position, y_position, train_height)
                    break
                
                sys.stdout.flush()
                time.sleep(0.05 / self.speed)
                frame += 1
                
                # Stop when train is off screen
                if x_position + train_width < 0:
                    break
            
        finally:
            # Clean up
            self.clear_screen()
            sys.stdout.write(ANSI.SHOW_CURSOR)
            sys.stdout.flush()
    
    def _colorize_line(self, line: str) -> str:
        """Add colors to train line."""
        # Simple coloring based on characters
        colored = line
        colored = colored.replace('D', ANSI.RED + 'D' + ANSI.RESET)
        colored = colored.replace('_', ANSI.YELLOW + '_' + ANSI.RESET)
        colored = colored.replace('|', ANSI.BLUE + '|' + ANSI.RESET)
        colored = colored.replace('=', ANSI.GREEN + '=' + ANSI.RESET)
        colored = colored.replace('O', ANSI.WHITE + 'O' + ANSI.RESET)
        colored = colored.replace('o', ANSI.WHITE + 'o' + ANSI.RESET)
        colored = colored.replace('~', ANSI.CYAN + '~' + ANSI.RESET)
        return colored
    
    def _calculate_fly_path(self, train_height: int) -> List[int]:
        """Calculate flying path for train."""
        path = []
        total_frames = self.width + 60
        
        for i in range(total_frames):
            # Sinusoidal flight path
            progress = i / total_frames
            y = int((self.height - train_height) * (0.5 + 0.3 * 
                    (progress * progress * progress)))
            path.append(max(1, min(self.height - train_height, y)))
        
        return path
    
    def _show_accident(self, x_pos: int, y_pos: int, height: int):
        """Show accident/crash effect."""
        crash_art = [
            "    CRASH!    ",
            "     BOOM!    ",
            "   * * * * *  ",
            "  * BANG!! *  ",
            "   * * * * *  "
        ]
        
        for i, line in enumerate(crash_art):
            if 0 < y_pos + i <= self.height:
                sys.stdout.write(ANSI.move_cursor(x_pos + 10, y_pos + i))
                sys.stdout.write(ANSI.RED + line + ANSI.RESET)
        
        sys.stdout.flush()
        time.sleep(2)


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description='sl - Display animated steam locomotive',
        epilog='A joke command for when you type sl instead of ls'
    )
    
    parser.add_argument('-a', '--accident', action='store_true',
                        help='An accident occurs')
    parser.add_argument('-F', '--fly', action='store_true',
                        help='Make the train fly')
    parser.add_argument('-l', '--long', action='store_true',
                        help='Use a longer train')
    parser.add_argument('-c', '--C51', action='store_true',
                        help='Use C51 train type')
    parser.add_argument('-s', '--speed', type=float, default=1.0,
                        help='Animation speed multiplier (default: 1.0)')
    parser.add_argument('-v', '--version', action='version',
                        version=f'sl version {__version__}')
    
    args = parser.parse_args()
    
    # Determine train type
    if args.C51:
        train_type = "C51"
    elif args.long:
        train_type = "D51"
    else:
        train_type = "classic"
    
    # Run animation
    animation = SLAnimation(
        train_type=train_type,
        speed=args.speed,
        fly=args.fly,
        accident=args.accident
    )
    
    animation.run()


if __name__ == "__main__":
    main()