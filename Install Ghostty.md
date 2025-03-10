# Install Ghostty

### Install Ghostty
**Ghostty** - A fast, feature-rich, and cross-platform terminal emulator that uses platform-native UI and GPU acceleration. [Website](https://https://ghostty.org/)

An Ubuntu package (.deb) is available from [ghostty-ubuntu](https://github.com/mkasberg/ghostty-ubuntu) on GitHub. After downloading the .deb for your Ubuntu version from the [Releases](https://github.com/mkasberg/ghostty-ubuntu/releases) page, install it as below:
```bash
# Replace the URL with the latest release URL
wget https://github.com/mkasberg/ghostty-ubuntu/releases/download/1.1.2-0-ppa1/ghostty_1.1.2-0.ppa1_amd64_22.04.deb

# Install the downloaded .deb package, replace the package name with the downloaded package
sudo dpkg -i ghostty_1.1.2-0.ppa1_amd64_22.04.deb
```

### Make Ghostty your default 
To make Ghostty your default terminal, run:
```bash
sudo update-alternatives --config x-terminal-emulator
```