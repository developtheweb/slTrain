import os
import time
import sys
import random
from colorama import init, Fore, Back, Style

# Initialize colorama
init(autoreset=True)

def clear_screen():
    os.system('cls' if os.name == 'nt' else 'clear')

def get_smoke_pattern(length):
    pattern = [' '] * length
    for i in range(length):
        if random.random() < 0.7:  # 70% chance of smoke
            pattern[i] = random.choice(['o', '.'])
    return ''.join(pattern)

def print_train(position, smoke_pattern):
    train = [
        f"{Fore.WHITE}{' ' * 19}{smoke_pattern}",
        f"{Fore.RED}   _____ {Fore.WHITE}{' ' * 17}{smoke_pattern[:5]}",
        f"{Fore.RED}  __|[_]|__ {Fore.GREEN}___________ _______{Fore.WHITE}    ____      o",
        f"{Fore.RED} |{Fore.YELLOW}[] [] []{Fore.RED}| {Fore.YELLOW}[] [] [] [] {Fore.RED}[_____(_{Fore.WHITE}_  {Fore.BLUE}]{Fore.YELLOW}]]_n_n__{Fore.BLUE}][.",
        f"{Fore.YELLOW}_|{Fore.WHITE}________|{Fore.YELLOW}_[_________]_[________]_{Fore.BLUE}|__|________)<",
        f"{Fore.WHITE}  oo    oo 'oo      oo ' oo    oo 'oo 0000---oo\\_",
        f"{Fore.CYAN}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    ]
    for line in train:
        print(" " * position + line)

def animate_train():
    width = os.get_terminal_size().columns
    train_length = 65  # Length of the train
    smoke_length = 25  # Length of smoke trail

    # Start with the train partially on screen
    start_position = 5  # Adjust this value to change how much of the train is visible at start

    for i in range(start_position, width + train_length):
        clear_screen()
        smoke_pattern = get_smoke_pattern(smoke_length)
        print_train(i - train_length, smoke_pattern)
        time.sleep(0.1)
        sys.stdout.flush()

        # Stop when the train has fully left the screen
        if i >= width:
            break

if __name__ == "__main__":
    animate_train()
