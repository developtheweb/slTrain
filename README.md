# 🚂 sl - Steam Locomotive

[![GitHub stars](https://img.shields.io/github/stars/developtheweb/slTrain?style=social)](https://github.com/developtheweb/slTrain/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/developtheweb/slTrain?style=social)](https://github.com/developtheweb/slTrain/network/members)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python](https://img.shields.io/badge/python-3.6+-blue.svg)](https://www.python.org/downloads/)
[![Platform](https://img.shields.io/badge/platform-linux%20%7C%20macos%20%7C%20unix-lightgrey.svg)](https://github.com/developtheweb/slTrain)
[![Maintained](https://img.shields.io/badge/maintained-yes-green.svg)](https://github.com/developtheweb/slTrain/commits/main)
[![Website](https://img.shields.io/badge/website-StevenMilanese.com-blue.svg)](https://stevenmilanese.com)

A joke command that displays an animated steam locomotive in your terminal when you accidentally type 'sl' instead of 'ls'.

```
      ====        ________                ___________
  _D _|  |_______/        \__I_I_____===__|_________|
   |(_)---  |   H\________/ |   |        =|___ ___|  
   /     |  |   H  |  |     |   |         ||_| |_||  
  |      |  |   H  |__--------------------| [___] |  
  | ________|___H__/__|_____/[][]~\_______|       |  
  |/ |   |-----------I_____I [][] []  D   |=======|__
__/ =| o |=-~~\  /~~\  /~~\  /~~\ ____Y___________|__
 |/-=|___|=    ||    ||    ||    |_____/~\___/       
  \_/      \O=====O=====O=====O_/      \_/           
```

## 🎥 Demo

![sl command demo](https://raw.githubusercontent.com/developtheweb/slTrain/main/assets/sl-demo.gif)

*Watch the train cross your terminal when you mistype!*

## ✨ Features

- 🚂 **Multiple train types** - Classic, D51, and C51 locomotives
- ✈️ **Flying mode** - Make the train fly across the sky (`-F`)
- 💥 **Accident mode** - Watch a dramatic crash (`-a`)
- 🎨 **Colorful ASCII art** - Beautiful colored trains with dynamic smoke
- ⚡ **Adjustable speed** - Control animation speed
- 📐 **Terminal-aware** - Handles terminal resizing gracefully
- 🛡️ **Clean exit** - Proper cleanup and Ctrl+C handling
- 🪶 **Lightweight** - No external dependencies, pure Python

## 📦 Installation

### Quick Install (Recommended)

```bash
# Clone the repository
git clone https://github.com/developtheweb/slTrain.git
cd slTrain

# Install to /usr/local/bin
sudo make install
```

### Platform-Specific Instructions

<details>
<summary><b>🐧 Linux</b></summary>

```bash
# Debian/Ubuntu
git clone https://github.com/developtheweb/slTrain.git
cd slTrain
sudo make install

# Arch Linux (AUR)
# Coming soon!

# Manual install
sudo cp sl /usr/local/bin/
sudo chmod +x /usr/local/bin/sl
```
</details>

<details>
<summary><b>🍎 macOS</b></summary>

```bash
# Using Homebrew (coming soon)
# brew install sl

# Manual install
git clone https://github.com/developtheweb/slTrain.git
cd slTrain
sudo make install
```
</details>

<details>
<summary><b>🐳 Docker</b></summary>

```bash
# Run without installing
docker run --rm -it ghcr.io/developtheweb/sl:latest

# Alias for easy use
alias sl='docker run --rm -it ghcr.io/developtheweb/sl:latest'
```
</details>

### Uninstall

```bash
sudo make uninstall
# or
sudo rm /usr/local/bin/sl
```

## 🚀 Usage

Simply type `sl` instead of `ls`:

```bash
$ sl              # Classic train
$ sl -F           # Flying train
$ sl -a           # Train accident
$ sl -c           # C51 train type
$ sl -l           # Long train (D51)
$ sl -s 2.0       # Double speed
$ sl --help       # Show help
```

### Options

| Option | Long Form | Description |
|--------|-----------|-------------|
| `-a` | `--accident` | An accident occurs partway through |
| `-F` | `--fly` | Make the train fly through the sky |
| `-l` | `--long` | Use a longer train (D51) |
| `-c` | `--C51` | Use the C51 train type |
| `-s` | `--speed` | Animation speed multiplier (default: 1.0) |
| `-v` | `--version` | Show version information |
| `-h` | `--help` | Show help message |

## 🤔 Why sl?

We've all done it - typed `sl` when we meant `ls`. Instead of getting an error, why not get a gentle reminder in the form of a steam locomotive chugging across your terminal? 

### Benefits:
- 📚 **Learn to type more carefully** - Muscle memory training through humor
- 😄 **Add whimsy to your command line** - Because terminals can be fun too
- 🎭 **Surprise your coworkers** - Watch their confusion turn to delight
- 🧘 **Take a brief mental break** - Sometimes you need a train break

## 📋 Requirements

- Python 3.6 or higher
- Unix-like terminal with ANSI escape code support
- A sense of humor 😄

## 🤝 Contributing

We love contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Quick Start for Contributors

```bash
# Fork and clone the repository
git clone https://github.com/YOUR_USERNAME/slTrain.git
cd slTrain

# Create a feature branch
git checkout -b feature/amazing-feature

# Make your changes and test
./sl -F  # Test your changes

# Commit and push
git commit -m "Add amazing feature"
git push origin feature/amazing-feature
```

## 💖 Support the Project

If you enjoy `sl`, consider supporting the development:

- ⭐ **Star this repository** - It helps others discover the project
- 🐛 **Report bugs** - Help us improve by [reporting issues](https://github.com/developtheweb/slTrain/issues)
- 💡 **Suggest features** - Share your ideas for new train types or animations
- 🌐 **Visit my website** - Learn more at [StevenMilanese.com](https://stevenmilanese.com)
- ☕ **Buy me a coffee** - Support development at [StevenMilanese.com/support](https://stevenmilanese.com/support)

## 🔒 Security

Found a security issue? Please see our [Security Policy](SECURITY.md) for responsible disclosure.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Reverend Steven Milanese**

- 🌐 Website: [StevenMilanese.com](https://stevenmilanese.com)
- 📧 Email: [contact@stevenmilanese.com](mailto:contact@stevenmilanese.com)
- 🐙 GitHub: [@developtheweb](https://github.com/developtheweb)
- 💼 LinkedIn: [Connect with me](https://stevenmilanese.com/linkedin)

## 🙏 Acknowledgments

- Inspired by the original `sl` command by Toyoda Masashi
- ASCII art trains adapted from various sources
- Thanks to all [contributors](https://github.com/developtheweb/slTrain/graphs/contributors) who have helped improve this project
- Special thanks to the first stargazer who inspired this update! ⭐

## 📊 Project Stats

![GitHub commit activity](https://img.shields.io/github/commit-activity/m/developtheweb/slTrain)
![GitHub last commit](https://img.shields.io/github/last-commit/developtheweb/slTrain)
![GitHub code size](https://img.shields.io/github/languages/code-size/developtheweb/slTrain)

---

<p align="center">
  <i>Remember: It's not a bug, it's a feature! 🚂</i>
  <br><br>
  Made with ❤️ by <a href="https://stevenmilanese.com">Reverend Steven Milanese</a>
  <br>
  <a href="https://stevenmilanese.com">Visit StevenMilanese.com</a> for more projects
</p>