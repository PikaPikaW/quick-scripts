#!/usr/bin/env bash

# ZSH 一键安装配置脚本
# 使用方法：curl -fsSL https://raw.githubusercontent.com/你的仓库/zsh-setup.sh | bash

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 日志函数
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 检查操作系统
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [[ -f /etc/os-release ]]; then
            . /etc/os-release
            OS=$NAME
            VER=$VERSION_ID
        elif command_exists lsb_release; then
            OS=$(lsb_release -si)
            VER=$(lsb_release -sr)
        else
            OS=$(uname -s)
            VER=$(uname -r)
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macOS"
        VER=$(sw_vers -productVersion)
    else
        OS="Unknown"
        VER=""
    fi
    log_info "检测到操作系统: $OS $VER"
}

# 安装 zsh
install_zsh() {
    log_info "开始安装 zsh..."
    
    if command_exists zsh; then
        log_success "zsh 已安装: $(zsh --version)"
        return 0
    fi
    
    case "$OS" in
        "Ubuntu"|"Debian GNU/Linux")
            sudo apt-get update
            sudo apt-get install -y zsh
            ;;
        "CentOS Linux"|"Red Hat Enterprise Linux")
            sudo yum install -y zsh
            ;;
        "Fedora")
            sudo dnf install -y zsh
            ;;
        "macOS")
            if command_exists brew; then
                brew install zsh
            else
                log_warning "macOS 系统推荐先安装 Homebrew"
                read -p "是否安装 Homebrew？[y/N]: " install_brew
                if [[ "$install_brew" =~ ^[Yy]$ ]]; then
                    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                    brew install zsh
                else
                    log_error "请手动安装 zsh"
                    exit 1
                fi
            fi
            ;;
        *)
            log_error "不支持的 OS: $OS"
            log_info "请手动安装 zsh"
            exit 1
            ;;
    esac
    
    if command_exists zsh; then
        log_success "zsh 安装成功"
    else
        log_error "zsh 安装失败"
        exit 1
    fi
}

# 设置 zsh 为默认 shell
set_default_shell() {
    log_info "设置 zsh 为默认 shell..."
    
    current_shell=$(echo $SHELL)
    zsh_path=$(which zsh)
    
    if [[ "$current_shell" == "$zsh_path" ]]; then
        log_success "zsh 已经是默认 shell"
        return 0
    fi
    
    if [[ "$SHELL" == *"zsh"* ]]; then
        log_success "zsh 已经是默认 shell"
        return 0
    fi
    
    # 检查是否在 /etc/shells 中
    if ! grep -q "$zsh_path" /etc/shells; then
        log_info "将 zsh 添加到 /etc/shells"
        echo "$zsh_path" | sudo tee -a /etc/shells
    fi
    
    # 设置默认 shell
    if chsh -s "$zsh_path"; then
        log_success "已设置 zsh 为默认 shell"
        log_warning "需要重新登录或重启终端生效"
    else
        log_error "设置默认 shell 失败，请手动执行: chsh -s $(which zsh)"
    fi
}

# 安装 Oh My Zsh
install_ohmyzsh() {
    log_info "准备安装 Oh My Zsh..."
    
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log_warning "Oh My Zsh 已安装"
        return 0
    fi
    
    read -p "是否安装 Oh My Zsh？[Y/n]: " install_omz
    install_omz=${install_omz:-Y}
    
    if [[ "$install_omz" =~ ^[Yy]$ ]]; then
        log_info "正在安装 Oh My Zsh..."
        
        # 备份现有的 .zshrc
        if [[ -f "$HOME/.zshrc" ]]; then
            cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
            log_info "已备份原有的 .zshrc 文件"
        fi
        
        # 安装 Oh My Zsh
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        
        if [[ -d "$HOME/.oh-my-zsh" ]]; then
            log_success "Oh My Zsh 安装成功"
        else
            log_error "Oh My Zsh 安装失败"
        fi
    else
        log_info "跳过 Oh My Zsh 安装"
    fi
}

# 选择主题
choose_theme() {
    log_info "选择 zsh 主题..."
    
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log_info "未安装 Oh My Zsh，跳过主题选择"
        return 0
    fi
    
    echo -e "${CYAN}可用的主题选项:${NC}"
    echo "1) Powerlevel10k (推荐，功能强大)"
    echo "2) Spaceship (现代美观)"
    echo "3) Agnoster (经典主题)"
    echo "4) Robbyrussell (Oh My Zsh 默认)"
    echo "5) 暂不安装主题"
    
    read -p "请选择主题 [1-5]: " theme_choice
    
    case $theme_choice in
        1)
            theme_name="powerlevel10k/powerlevel10k"
            install_powerlevel10k
            ;;
        2)
            theme_name="spaceship"
            install_spaceship
            ;;
        3)
            theme_name="agnoster"
            ;;
        4)
            theme_name="robbyrussell"
            ;;
        *)
            theme_name="robbyrussell"
            log_info "使用默认主题"
            return 0
            ;;
    esac
    
    # 更新 .zshrc 中的主题设置
    if [[ -f "$HOME/.zshrc" ]]; then
        sed -i.bak "s|^ZSH_THEME=.*|ZSH_THEME=\"$theme_name\"|" "$HOME/.zshrc"
        log_success "已设置主题为: $theme_name"
    fi
}

# 安装 Powerlevel10k
install_powerlevel10k() {
    log_info "安装 Powerlevel10k 主题..."
    
    if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
        log_success "Powerlevel10k 安装成功"
    else
        log_info "Powerlevel10k 已安装"
    fi
    
    log_warning "安装完成后，请运行 'p10k configure' 进行配置"
}

# 安装 Spaceship 主题
install_spaceship() {
    log_info "安装 Spaceship 主题..."
    
    if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/spaceship-prompt" ]]; then
        git clone https://github.com/spaceship-prompt/spaceship-prompt.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/spaceship-prompt" --depth=1
        ln -s "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/spaceship-prompt/spaceship.zsh-theme" "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/spaceship.zsh-theme"
        log_success "Spaceship 主题安装成功"
    else
        log_info "Spaceship 主题已安装"
    fi
}

# 安装插件
install_plugins() {
    log_info "安装常用插件..."
    
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log_info "未安装 Oh My Zsh，跳过插件安装"
        return 0
    fi
    
    echo -e "${CYAN}选择要安装的插件:${NC}"
    echo "1) 语法高亮 (zsh-syntax-highlighting)"
    echo "2) 自动建议 (zsh-autosuggestions)"
    echo "3) 自动补全 (zsh-completions)"
    echo "4) 历史搜索 (zsh-history-substring-search)"
    echo "5) 文件跳转 (zsh-z)"
    echo "6) 全部安装"
    echo "7) 暂不安装"
    
    read -p "请选择 (可多选，用逗号分隔，如 1,2,3): " plugin_choices
    
    IFS=',' read -ra plugins_array <<< "$plugin_choices"
    
    for choice in "${plugins_array[@]}"; do
        case $choice in
            1) install_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git" ;;
            2) install_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions.git" ;;
            3) install_plugin "zsh-completions" "https://github.com/zsh-users/zsh-completions.git" ;;
            4) install_plugin "zsh-history-substring-search" "https://github.com/zsh-users/zsh-history-substring-search.git" ;;
            5) install_plugin "zsh-z" "https://github.com/agkozak/zsh-z.git" ;;
            6)
                install_all_plugins
                break
                ;;
            7) log_info "跳过插件安装" ;;
        esac
    done
    
    # 更新 .zshrc 中的插件配置
    update_plugins_config
}

# 安装单个插件
install_plugin() {
    local plugin_name=$1
    local repo_url=$2
    local plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin_name"
    
    if [[ ! -d "$plugin_dir" ]]; then
        log_info "正在安装插件: $plugin_name"
        git clone "$repo_url" "$plugin_dir"
        log_success "插件 $plugin_name 安装成功"
    else
        log_info "插件 $plugin_name 已存在"
    fi
}

# 安装所有插件
install_all_plugins() {
    log_info "安装所有推荐插件..."
    
    install_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"
    install_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions.git"
    install_plugin "zsh-completions" "https://github.com/zsh-users/zsh-completions.git"
    install_plugin "zsh-history-substring-search" "https://github.com/zsh-users/zsh-history-substring-search.git"
    install_plugin "zsh-z" "https://github.com/agkozak/zsh-z.git"
}

# 更新插件配置
update_plugins_config() {
    if [[ -f "$HOME/.zshrc" ]]; then
        # 基础插件列表
        base_plugins="git"
        
        # 添加已安装的插件
        declare -A installed_plugins
        installed_plugins=(
            ["zsh-syntax-highlighting"]="zsh-syntax-highlighting"
            ["zsh-autosuggestions"]="zsh-autosuggestions"
            ["zsh-completions"]="zsh-completions"
            ["zsh-history-substring-search"]="zsh-history-substring-search"
            ["zsh-z"]="zsh-z"
        )
        
        plugins="$base_plugins"
        for plugin in "${!installed_plugins[@]}"; do
            if [[ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin" ]]; then
                plugins="$plugins $plugin"
            fi
        done
        
        # 更新 .zshrc 中的插件配置
        sed -i.bak "s/^plugins=.*/plugins=($plugins)/" "$HOME/.zshrc"
        log_success "已更新插件配置"
    fi
}

# 配置 .zshrc
configure_zshrc() {
    log_info "配置 .zshrc..."
    
    if [[ ! -f "$HOME/.zshrc" ]]; then
        cp "$HOME/.oh-my-zsh/templates/zshrc.zsh-template" "$HOME/.zshrc"
    fi
    
    # 添加常用别名和配置
    cat >> "$HOME/.zshrc" << 'EOF'

# ===== 自定义配置 =====

# 加载 .bashrc 中的环境变量
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# 常用别名
alias ll='ls -la'
alias la='ls -A'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias zshconfig="vim ~/.zshrc"
alias ohmyzsh="vim ~/.oh-my-zsh"
alias reload="source ~/.zshrc"

# Git 别名
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gcm='git commit -m'
alias gco='git checkout'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'

# 函数：创建目录并进入
mkcd() { mkdir -p "$1" && cd "$1"; }

# 函数：查找进程
psgrep() { ps aux | grep -v grep | grep "$@" -i --color=auto; }

# 历史配置
export HISTSIZE=10000
export SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt SHARE_HISTORY

# 启用颜色
export CLICOLOR=1

# 设置编辑器
export EDITOR=vim

# 自动纠正命令
setopt CORRECT
setopt CORRECT_ALL

# 增强的自动补全
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' group-name ''
EOF
    
    log_success ".zshrc 配置完成"
}

# 安装字体（可选）
install_fonts() {
    log_info "安装 Nerd Fonts（推荐用于图标显示）..."
    
    read -p "是否安装 Nerd Fonts？[y/N]: " install_font
    if [[ ! "$install_font" =~ ^[Yy]$ ]]; then
        log_info "跳过字体安装"
        return 0
    fi
    
    case "$OS" in
        "macOS")
            if command_exists brew; then
                brew tap homebrew/cask-fonts
                brew install --cask font-hack-nerd-font
                log_success "Hack Nerd Font 安装成功"
            else
                log_warning "请手动安装 Nerd Fonts"
            fi
            ;;
        "Ubuntu"|"Debian GNU/Linux")
            sudo apt-get install -y fonts-hack-ttf
            log_success "Hack 字体安装成功"
            ;;
        *)
            log_warning "请手动下载并安装 Nerd Fonts："
            log_info "访问：https://www.nerdfonts.com/font-downloads"
            ;;
    esac
}

# 显示完成信息
show_completion() {
    echo -e "\n${GREEN}✅ ZSH 安装配置完成！${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}重要提示：${NC}"
    
    if [[ "$OS" == "macOS" ]]; then
        echo "1. 请在终端应用中设置字体为 'Hack Nerd Font'"
        echo "2. 可能需要重启终端应用"
    fi
    
    echo "3. 如果更改了默认 shell，请重新登录或重启终端"
    echo -e "\n${GREEN}常用命令：${NC}"
    echo "  zshconfig    # 编辑 zsh 配置"
    echo "  ohmyzsh      # 编辑 Oh My Zsh 配置"
    echo "  reload       # 重新加载配置"
    
    if [[ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
        echo -e "\n${YELLOW}运行以下命令配置 Powerlevel10k：${NC}"
        echo "  p10k configure"
    fi
    
    echo -e "\n${CYAN}享受你的新终端体验！✨${NC}"
}

# 主函数
main() {
    echo -e "${CYAN}════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}       ZSH 一键安装配置脚本${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════${NC}"
    
    # 检测操作系统
    detect_os
    
    # 安装 zsh
    install_zsh
    
    # 设置默认 shell
    set_default_shell
    
    # 安装 Oh My Zsh
    install_ohmyzsh
    
    # 选择主题
    choose_theme
    
    # 安装插件
    install_plugins
    
    # 配置 .zshrc
    configure_zshrc
    
    # 安装字体
    install_fonts
    
    # 显示完成信息
    show_completion
}

# 运行主函数
main "$@"
