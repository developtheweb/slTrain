# 🚂 sl — Steam Locomotive

[![GitHub stars](https://img.shields.io/github/stars/developtheweb/slTrain?style=social)](https://github.com/developtheweb/slTrain/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/developtheweb/slTrain?style=social)](https://github.com/developtheweb/slTrain/network/members)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python](https://img.shields.io/badge/python-3.6+-blue.svg)](https://www.python.org/downloads/)
[![Platform](https://img.shields.io/badge/platform-linux%20%7C%20macos%20%7C%20unix-lightgrey.svg)](https://github.com/developtheweb/slTrain)
[![Dependencies](https://img.shields.io/badge/dependencies-none-brightgreen.svg)](requirements.txt)
[![Maintained](https://img.shields.io/badge/maintained-yes-green.svg)](https://github.com/developtheweb/slTrain/commits/main)
[![Website](https://img.shields.io/badge/website-StevenMilanese.com-blue.svg)](https://stevenmilanese.com)

> You typed `sl`. You meant `ls`. The railroad thanks you for your patronage.

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

Every other command punishes a typo with an error message. `sl` rewards it
with a steam locomotive. The entire point is maximal output for minimal
input — two mistyped letters buy you a train, and you *will* watch it cross
your terminal, because that is the punishment and the prize.

This is a single-file, zero-dependency Python train that takes the joke
entirely too seriously: a flicker-free double-buffered renderer, wheels that
actually turn, smoke that drifts and dissipates, coal cars, a whistle, and a
crash mode that earns its flag.

## 🎲 No two typos look alike

A bare `sl` — the classic fumbled `ls` — rolls the dice on everything:
locomotive type, coal-car count, color livery (four named themes plus
fully random one-offs), and speed. Sometimes it whistles. Rarely, it flies.
Very rarely, it does not make it across.

| Event | Odds |
|-------|------|
| 📣 The train whistles | 1 in 4 |
| ✈️ The train takes flight | 1 in 10 |
| 💥 The train does not arrive at the station | 1 in 20 |

Pass any flag and the dice are off — explicit options are fully
deterministic, so your customizations always behave exactly as written.

## ✨ Features

- 🎲 **Surprise mode** — a bare `sl` randomizes the whole show, every run
- 🚂 **Four locomotives** — Classic, Small, D51, and C51 (`-t`)
- 🛞 **Animated wheels** — a 4-frame rotation cycle on every engine
- 💨 **Particle smoke** — drifts behind the train and dissipates, with grayscale shading on 256-color terminals
- 🚃 **Coal cars** — couple up to 8 tenders behind the engine (`-n`)
- ✈️ **Flying mode** — smoothstep climb with a stardust trail (`-F`)
- 💥 **Accident mode** — screen shake, a spark shower, and a proper BOOM (`-a`)
- 📣 **Whistle** — the train toots as it passes (`-w`)
- 🖥️ **Flicker-free** — double-buffered frames on the alternate screen; your terminal contents come back when the train has passed
- 🎨 **Respectful of your eyes** — honors `NO_COLOR` and `--no-color`; `sl | cat` prints a static train instead of escape-code soup
- 📐 **Terminal-aware** — live resize handling, clean Ctrl+C, monotonic frame pacing that doesn't drift
- 🪶 **Zero dependencies** — one file, pure Python standard library

## 📦 Installation

```bash
git clone https://github.com/developtheweb/slTrain.git
cd slTrain
sudo make install
```

That installs to `/usr/local/bin/sl`. Prefer to do it by hand?

```bash
sudo cp sl /usr/local/bin/ && sudo chmod +x /usr/local/bin/sl
```

**Requirements:** Python 3.6+, a Unix-like terminal with ANSI escape
support, and a sense of humor. Nothing else — see
[requirements.txt](requirements.txt), which is proudly empty.

### Uninstall

```bash
sudo make uninstall
```

The train will remember this.

## 🚀 Usage

You don't *use* `sl`. You commit a typo, and `sl` happens to you:

```bash
$ sl              # 🎲 Surprise! Random train, livery, cars, and speed
```

But if you insist on driving:

```bash
$ sl -t classic   # The classic engine, no surprises
$ sl -l           # Long train: D51 pulling coal cars
$ sl -n 8         # Maximum coal. The economy is booming
$ sl -F           # Flight
$ sl -a           # Tragedy
$ sl -w -c        # A whistling C51
$ sl -s 2.0       # You have somewhere to be
$ sl -s 0.1       # You do not
```

### Options

| Option | Long Form | Description |
|--------|-----------|-------------|
| `-a` | `--accident` | An accident occurs partway through |
| `-F` | `--fly` | Make the train fly through the sky |
| `-l` | `--long` | Use a longer train (D51 pulling coal cars) |
| `-c` | `--C51` | Use the C51 train type |
| `-t` | `--type` | Locomotive type: `classic`, `small`, `d51`, `c51` (overrides `-l`/`-c`) |
| `-n` | `--cars` | Number of coal cars to pull, up to 8 (default: 0) |
| `-w` | `--whistle` | Sound the whistle as the train passes |
| `-s` | `--speed` | Animation speed multiplier, 0.1–20 (default: 1.0) |
| | `--no-color` | Disable colors (`NO_COLOR` is also honored) |
| `-v` | `--version` | Show version information |
| `-h` | `--help` | Show help message |

Any flag disables surprise mode. The dice only roll for a naked typo.

## 🔧 How it works

For a joke, it's built like it matters:

- **Double-buffered rendering.** Each frame is composed into an off-screen
  cell buffer and emitted as a single write — no clear-screen between
  frames, so nothing flickers, ever.
- **The alternate screen.** The animation runs on the terminal's alternate
  buffer, the same trick `vim` and `less` use. When the train is gone, your
  scrollback is exactly as you left it. Like it never happened. It happened.
- **A particle system.** Smoke, crash sparks, and stardust are particles
  with velocity, drag, and gravity, aging through character ramps
  (`@` → `O` → `o` → `*` → `.`) as they dissipate.
- **Monotonic pacing.** Frame timing is anchored to a monotonic clock, so
  the train's speed doesn't drift with render cost or system load.
- **An honest fallback.** If stdout isn't a terminal, you get a static
  train in plain text. `sl | cat` is a train. `sl > file.txt` is a train.
  There is no escaping the train, only escape codes, and those are omitted.

## 🤔 Why does this exist?

We've all done it — typed `sl` when we meant `ls`. Instead of
`command not found`, why not a gentle reminder in the form of a steam
locomotive chugging across your terminal?

- 📚 **Typing discipline through consequences** — muscle memory training, enforced by rail
- 😄 **Whimsy in the command line** — terminals can be fun too
- 🎭 **Coworker delight** — watch confusion turn to joy, then back to confusion when it crashes
- 🧘 **Mandatory micro-breaks** — the train cannot be skipped, only awaited

## ❓ FAQ

**Can I stop the train?**
Ctrl+C works and exits cleanly. Learning to type `ls` also works, but nobody
has ever managed it.

**The train crashed. Is that a bug?**
If you passed `-a`, that's a feature. If you didn't, that's a 1-in-20 roll
of surprise mode, and honestly, it's a little bit on you for typing `sl`.

**Why would a train fly?**
1-in-10 odds say you'll find out.

**Is this compatible with the original `sl`?**
The spirit, the D51/C51 art heritage, and the `-a`/`-F`/`-l`/`-c` flags are
all honored. The renderer, particles, and surprise mode are new.

## 🤝 Contributing

Contributions are welcome — new locomotives, new liveries, new disasters.
See the [Contributing Guidelines](CONTRIBUTING.md).

```bash
git clone https://github.com/YOUR_USERNAME/slTrain.git
cd slTrain
git checkout -b feature/amazing-feature
./sl -F                  # test your changes
git commit -m "Add amazing feature"
git push origin feature/amazing-feature
```

## 💖 Support the Project

- ⭐ **Star this repository** — it helps others discover the train
- 🐛 **Report bugs** — [open an issue](https://github.com/developtheweb/slTrain/issues)
- 💡 **Suggest features** — new train types, animations, or calamities
- 🌐 **Visit my website** — [StevenMilanese.com](https://stevenmilanese.com)
- ☕ **Buy me a coffee** — [StevenMilanese.com/support](https://stevenmilanese.com/support)

## 📝 License

MIT — see [LICENSE](LICENSE). The train is free. The train has always been
free.

## 👨‍💻 Author

**Reverend Steven Milanese**

- 🌐 Website: [StevenMilanese.com](https://stevenmilanese.com)
- 📧 Email: [contact@stevenmilanese.com](mailto:contact@stevenmilanese.com)
- 🐙 GitHub: [@developtheweb](https://github.com/developtheweb)
- 💼 LinkedIn: [Connect with me](https://stevenmilanese.com/linkedin)

## 🙏 Acknowledgments

- Inspired by the original `sl` by **Toyoda Masashi** (1993), who understood
  that the punishment for a typo should be beautiful
- The coal car art is adapted from the original `sl`
- Thanks to all [contributors](https://github.com/developtheweb/slTrain/graphs/contributors)
- Special thanks to the first stargazer who inspired this update ⭐

## 📊 Project Stats

![GitHub commit activity](https://img.shields.io/github/commit-activity/m/developtheweb/slTrain)
![GitHub last commit](https://img.shields.io/github/last-commit/developtheweb/slTrain)
![GitHub code size](https://img.shields.io/github/languages/code-size/developtheweb/slTrain)

---

<p align="center">
  <i>It's not a bug, it's a locomotive. 🚂</i>
  <br><br>
  Made with ❤️ by <a href="https://stevenmilanese.com">Reverend Steven Milanese</a>
  <br>
  <a href="https://stevenmilanese.com">Visit StevenMilanese.com</a> for more projects
</p>
