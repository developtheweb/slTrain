# Contributing to sl - Steam Locomotive

First off, thank you for considering contributing to sl! It's people like you that make sl such a fun tool. 🚂

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Process](#development-process)
- [Style Guidelines](#style-guidelines)
- [Community](#community)

## 📜 Code of Conduct

This project and everyone participating in it is governed by the [sl Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to [contact@stevenmilanese.com](mailto:contact@stevenmilanese.com).

## 🚀 Getting Started

### Prerequisites

- Python 3.6 or higher
- Git
- A Unix-like terminal (Linux, macOS, WSL on Windows)
- Basic knowledge of Python and ASCII art

### Setting Up Your Development Environment

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/slTrain.git
   cd slTrain
   ```
3. **Add the upstream repository**:
   ```bash
   git remote add upstream https://github.com/developtheweb/slTrain.git
   ```
4. **Create a branch** for your feature or fix:
   ```bash
   git checkout -b feature/your-feature-name
   ```

### Testing Your Changes

Always test your changes before submitting:

```bash
# Basic test
./sl

# Test all options
./sl -F     # Flying mode
./sl -a     # Accident mode
./sl -c     # C51 train
./sl -l     # Long train

# Run the demo suite
make demo
```

## 🤝 How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When you create a bug report, include:

- **Clear and descriptive title**
- **Steps to reproduce** the issue
- **Expected behavior** vs what actually happened
- **Screenshots** if applicable
- **System information** (OS, Python version, terminal type)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When suggesting an enhancement:

- **Use a clear and descriptive title**
- **Provide a detailed description** of the proposed feature
- **Explain why** this enhancement would be useful
- **Include mockups or examples** if applicable

### Pull Requests

1. **Follow the style guidelines** below
2. **Include meaningful commit messages**
3. **Update documentation** as needed
4. **Add tests** if applicable
5. **Ensure all tests pass**
6. **Update the CHANGELOG.md** with your changes

## 💻 Development Process

### Git Workflow

1. **Keep your fork up to date**:
   ```bash
   git checkout main
   git pull upstream main
   git push origin main
   ```

2. **Work on your feature branch**:
   ```bash
   git checkout -b feature/amazing-feature
   # Make your changes
   git add .
   git commit -m "Add amazing feature"
   ```

3. **Rebase if needed**:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

4. **Push and create PR**:
   ```bash
   git push origin feature/amazing-feature
   ```

### Commit Messages

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests liberally after the first line

Example:
```
Add flying saucer animation mode

- Implement UFO ASCII art variant
- Add --ufo flag to trigger the animation
- Update help documentation

Fixes #123
```

## 🎨 Style Guidelines

### Python Style

- Follow [PEP 8](https://www.python.org/dev/peps/pep-0008/)
- Use meaningful variable and function names
- Add docstrings to all functions and classes
- Keep functions small and focused
- Use type hints where appropriate

Example:
```python
def generate_smoke(length: int, density: float = 0.4) -> str:
    """
    Generate a smoke pattern for the locomotive.
    
    Args:
        length: Length of the smoke trail
        density: Probability of smoke character (0.0 to 1.0)
    
    Returns:
        String containing the smoke pattern
    """
    # Implementation here
```

### ASCII Art Guidelines

When adding new train types or modifying existing ones:

- Maintain consistent width across all lines
- Use appropriate characters for different parts:
  - `=` for rails and connections
  - `|` for vertical structures
  - `_` for horizontal surfaces
  - `O` or `o` for wheels
  - `~` for smoke trails
- Test the art at different terminal sizes
- Ensure proper alignment and spacing

### Documentation

- Update README.md if adding new features
- Include docstrings for all new functions
- Add comments for complex logic
- Update help text in the argument parser

## 🌟 Recognition

Contributors who submit accepted pull requests will be:
- Added to the contributors list
- Mentioned in the CHANGELOG.md
- Credited in release notes

## 🤔 Questions?

Feel free to:
- Open an issue for questions
- Email [contact@stevenmilanese.com](mailto:contact@stevenmilanese.com)
- Visit [StevenMilanese.com](https://stevenmilanese.com) for more information

## 📮 Community

- Star the repository to show support
- Share sl with friends and colleagues
- Write about your experience with sl
- Create ASCII art variations

Thank you for making sl better! 🚂 ❤️

---

*Happy coding! Remember, every great journey begins with a single `git commit`.*