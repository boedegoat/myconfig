#!/bin/bash

# Update and Upgrade
sudo apt update
sudo apt upgrade -y

# Install common dependencies
sudo apt install -y curl wget git build-essential

# 1. Unzip rockyou.txt.gz
echo "Setting up rockyou wordlist..."
if [ -f /usr/share/wordlists/rockyou.txt.gz ]; then
    sudo gzip -d /usr/share/wordlists/rockyou.txt.gz
    echo "Unzipped rockyou.txt.gz"
elif [ -f /usr/share/wordlists/rockyou.tar.gz ]; then
    sudo tar -xzf /usr/share/wordlists/rockyou.tar.gz -C /usr/share/wordlists/
    echo "Unzipped rockyou.tar.gz"
else
    echo "rockyou wordlist not found in /usr/share/wordlists/"
fi

# 2. Install Tools via APT
echo "Installing tools via APT..."
sudo apt install -y fastfetch tldr tmux zoxide eza duf btop dirsearch subfinder

# 3. Install NVM
echo "Installing NVM..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Load NVM for current script session
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# 4. Install Foundry (Solidity)
echo "Installing Foundry..."
curl -L https://foundry.paradigm.xyz | bash
# Run foundryup to install tools (forge, cast, anvil, chisel)
export PATH="$HOME/.foundry/bin:$PATH"
foundryup

# 5. Setup TMUX & TPM
echo "Setting up TMUX and TPM..."

# Clone TPM
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    echo "Cloned TPM repo"
else
    echo "TPM already installed"
fi

# Copy .tmux.conf from current directory to home
# Assuming script is run from the repo root
if [ -f ".tmux.conf" ]; then
    cp .tmux.conf ~/.tmux.conf
    echo "Copied .tmux.conf to ~/.tmux.conf"
else
    echo "Warning: .tmux.conf not found in current directory. Skipping config copy."
fi

# Reload tmux environment if tmux is running, otherwise user needs to start it
if pgrep tmux >/dev/null; then
    tmux source ~/.tmux.conf
    echo "Reloaded tmux config"
else
    echo "Tmux is not running. Start it with 'tmux' to see changes."
fi

# 6. Configure Shells (bash & zsh) for Zoxide, Eza, and NVM
echo "Configuring shell aliases and initializations..."

configure_shell() {
    local shell_rc="$1"
    local shell_name="$2"

    if [ -f "$shell_rc" ]; then
        echo "Updating $shell_rc..."
        
        # NVM Path Setup
        if ! grep -q "export NVM_DIR=\"\$HOME/.nvm\"" "$shell_rc"; then
            echo -e "\n# NVM configuration" >> "$shell_rc"
            echo 'export NVM_DIR="$HOME/.nvm"' >> "$shell_rc"
            echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm' >> "$shell_rc"
            echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion' >> "$shell_rc"
            echo "Added NVM configuration to $shell_rc"
        fi

        # Zoxide
        if ! grep -q "zoxide init" "$shell_rc"; then
            echo "eval \"\$(zoxide init $shell_name)\"" >> "$shell_rc"
            echo "Added zoxide init to $shell_rc"
        fi

        # Eza
        if ! grep -q "alias ls='eza'" "$shell_rc"; then
            echo "# Eza aliases" >> "$shell_rc"
            echo "alias ls='eza --icons'" >> "$shell_rc"
            echo "alias ll='eza -l --icons --git'" >> "$shell_rc"
            echo "alias la='eza -la --icons --git'" >> "$shell_rc"
            echo "alias tree='eza --tree --icons'" >> "$shell_rc"
            echo "Added eza aliases to $shell_rc"
        fi
    fi
}

configure_shell "$HOME/.bashrc" "bash"
configure_shell "$HOME/.zshrc" "zsh"

echo "Installation complete! Please restart your shell or source your profile."


