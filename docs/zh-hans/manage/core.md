# 核心

核心 `asdf` 命令列表很小，但可以促进很多工作流。

## 安装和配置

请查看 [快速上手](/zh-hans/guide/getting-started.md) 了解更多详情。

## Exec

```shell:no-line-numbers
asdf exec <command> [args...]
```

执行当前版本的命令垫片。

<!-- TODO: expand on this with example -->

## Env

```shell:no-line-numbers
asdf env <command> [util]
```

<!-- TODO: expand on this with example -->

## Info

```shell:no-line-numbers
asdf info
```

用于打印操作系统、Shell 和 `asdf` 调试信息的辅助命令。在报告 bug 时需要共享这些信息。

## Reshim

```shell:no-line-numbers
asdf reshim <name> <version>
```

这将为某个包的当前版本重新创建垫片。默认情况下，垫片是在某个工具安装的过程中由插件创建。一些工具像 [npm 命令行](https://docs.npmjs.com/cli/) 允许全局安装可执行程序，比如使用 `npm install -g yarn` 命令安装 [Yarn](https://yarnpkg.com/)。因为这个可执行程序不是通过插件生命周期安装的，所以还没有对应的垫片存在。`asdf reshim nodejs <version>` 命令将会强制重新计算任何新可执行程序的垫片，类似 `nodejs` 的 `versions` 版本下的 `yarn`。

## Shim-versions

```shell:no-line-numbers
asdf shim-versions <command>
```

列举为命令提供垫片的插件和版本。

例如，[Node.js](https://nodejs.org/) 附带了两个可执行程序，`node` 和 `npm`。当使用 [`asdf-nodejs`](https://github.com/asdf-vm/asdf-nodejs/)`插件安装了这些工具的很多版本时，执行`shim-versions` 命令会返回：

```shell:no-line-numbers
➜ asdf shim-versions node
nodejs 14.8.0
nodejs 14.17.3
nodejs 16.5.0
```

```shell:no-line-numbers
➜ asdf shim-versions npm
nodejs 14.8.0
nodejs 14.17.3
nodejs 16.5.0
```

## 更新

`asdf` 有一个依赖于 Git （我们推荐的安装方法）的内置命令用于更新。如果你使用了其他方法安装，则应按照该方法的步骤操作：

| 方法       | 最新稳定版本                                                                                                               | `master` 分支上的最新提交        |
| ---------- | -------------------------------------------------------------------------------------------------------------------------- | -------------------------------- |
| asdf (Git) | `asdf update`                                                                                                              | `asdf update --head`             |
| Homebrew   | `brew upgrade asdf`                                                                                                        | `brew upgrade asdf --fetch-HEAD` |
| Pacman     | 下载一个新的 `PKGBUILD` 并且重新编译 <br/> 或者使用你习惯的 [AUR helper](https://wiki.archlinux.org/index.php/AUR_helpers) |                                  |

## 卸载

根据以下步骤卸载 `asdf`：

::: details Bash & Git

1. 在 `~/.bashrc` 配置文件中移除生效 `asdf.sh` 和补全功能的行：

```shell
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash
```

2. 移除 `$HOME/.asdf` 目录：

```shell:no-line-numbers
rm -rf ${ASDF_DATA_DIR:-$HOME/.asdf}
```

3. 执行以下命令移除 `asdf` 所有配置文件：

```shell:no-line-numbers
rm -rf $HOME/.tool-versions $HOME/.asdfrc
```

:::

::: details Bash & Git (macOS)

1. 在 `~/.bash_profile` 配置文件中移除生效 `asdf.sh` 和补全功能的行：

```shell
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash
```

2. 移除 `$HOME/.asdf` 目录：

```shell:no-line-numbers
rm -rf ${ASDF_DATA_DIR:-$HOME/.asdf}
```

3. 执行以下命令移除 `asdf` 所有配置文件：

```shell:no-line-numbers
rm -rf $HOME/.tool-versions $HOME/.asdfrc
```

:::

::: details Bash & Homebrew (macOS)

如果你正在使用 **macOS Catalina 以及更新版本**，默认的 shell 已经变成了 **ZSH**。如果你在 `~/.bash_profile` 文件中找不到任何配置，则可能位于 `~/.zshrc` 中。在这种情况下，请按照 ZSH 指南进行操作。

1. 在 `~/.bash_profile` 配置文件中移除生效 `asdf.sh` 和补全功能的行：

```shell
. $(brew --prefix asdf)/libexec/asdf.sh
. $(brew --prefix asdf)/etc/bash_completion.d/asdf.bash
```

补全功能可能已经如 [Homebrew 的指南](https://docs.brew.sh/Shell-Completion#configuring-completions-in-bash) 那样配置了，因此请按照他们的指南找出要删除的内容。

2. 用包管理器卸载：

```shell:no-line-numbers
brew uninstall asdf --force
```

3. 执行以下命令移除 `asdf` 所有配置文件：

```shell:no-line-numbers
rm -rf $HOME/.tool-versions $HOME/.asdfrc
```

:::

::: details Bash & Pacman

1. 在 `~/.bashrc` 配置文件中移除生效 `asdf.sh` 和补全功能的行：

```shell
. /opt/asdf-vm/asdf.sh
```

2. 用包管理器卸载：

```shell:no-line-numbers
pacman -Rs asdf-vm
```

3. 移除 `$HOME/.asdf` 目录：

```shell:no-line-numbers
rm -rf ${ASDF_DATA_DIR:-$HOME/.asdf}
```

4. 执行以下命令移除 `asdf` 所有配置文件：

```shell:no-line-numbers
rm -rf $HOME/.tool-versions $HOME/.asdfrc
```

:::

::: details Fish & Git

1. 在 `~/.config/fish/config.fish` 配置文件中移除生效 `asdf.fish` 的行：

```shell
source ~/.asdf/asdf.fish
```

以及使用以下命令移除补全功能：

```shell:no-line-numbers
rm -rf ~/.config/fish/completions/asdf.fish
```

2. 移除 `$HOME/.asdf` 目录：

```shell:no-line-numbers
rm -rf ${ASDF_DATA_DIR:-$HOME/.asdf}
```

3. 执行以下命令移除 `asdf` 所有配置文件：

```shell:no-line-numbers
rm -rf $HOME/.tool-versions $HOME/.asdfrc
```

:::

::: details Fish & Homebrew

1. 在 `~/.config/fish/config.fish` 配置文件中移除生效 `asdf.fish` 的行：

```shell
source "(brew --prefix asdf)"/libexec/asdf.fish
```

2. 用包管理器卸载：

```shell:no-line-numbers
brew uninstall asdf --force
```

3. 执行以下命令移除 `asdf` 所有配置文件：

```shell:no-line-numbers
rm -rf $HOME/.tool-versions $HOME/.asdfrc
```

:::

::: details Fish & Pacman

1. 在 `~/.config/fish/config.fish` 配置文件中移除生效 `asdf.fish` 的行：

```shell
source /opt/asdf-vm/asdf.fish
```

2. 用包管理器卸载：

```shell:no-line-numbers
pacman -Rs asdf-vm
```

3. 移除 `$HOME/.asdf` 目录：

```shell:no-line-numbers
rm -rf ${ASDF_DATA_DIR:-$HOME/.asdf}
```

4. 执行以下命令移除 `asdf` 所有配置文件：

```shell:no-line-numbers
rm -rf $HOME/.tool-versions $HOME/.asdfrc
```

:::

::: details Elvish & Git

1. 在 `~/.config/elvish/rc.elv` 配置文件中移除使用 `asdf` 模块的行：

```shell
use asdf _asdf; var asdf~ = $_asdf:asdf~
```

以及使用以下命令卸载 `asdf` 模块：

```shell:no-line-numbers
rm -f ~/.config/elvish/lib/asdf.elv
```

2. 移除 `$HOME/.asdf` 目录：

```shell:no-line-numbers
if (!=s $E:ASDF_DATA_DIR "") { rm -rf $E:ASDF_DATA_DIR } else { rm -rf ~/.asdf }
```

3. 执行以下命令移除 `asdf` 所有配置文件：

```shell:no-line-numbers
rm -rf $HOME/.tool-versions $HOME/.asdfrc
```

:::

::: details Elvish & Homebrew

1. 在 `~/.config/elvish/rc.elv` 配置文件中移除使用 `asdf` 模块的行：

```shell
use asdf _asdf; var asdf~ = $_asdf:asdf~
```

以及使用以下命令卸载 `asdf` 模块：

```shell:no-line-numbers
rm -f ~/.config/elvish/lib/asdf.elv
```

2. 用包管理器卸载：

```shell:no-line-numbers
brew uninstall asdf --force
```

3. 执行以下命令移除 `asdf` 所有配置文件：

```shell:no-line-numbers
rm -rf $HOME/.tool-versions $HOME/.asdfrc
```

:::

::: details Elvish & Pacman

1. 在 `~/.config/elvish/rc.elv` 配置文件中移除使用 `asdf` 模块的行：

```shell
use asdf _asdf; var asdf~ = $_asdf:asdf~
```

以及使用以下命令卸载 `asdf` 模块：

```shell:no-line-numbers
rm -f ~/.config/elvish/lib/asdf.elv
```

2. 用包管理器卸载：

```shell:no-line-numbers
pacman -Rs asdf-vm
```

3. 移除 `$HOME/.asdf` 目录：

```shell:no-line-numbers
if (!=s $E:ASDF_DATA_DIR "") { rm -rf $E:ASDF_DATA_DIR } else { rm -rf ~/.asdf }
```

4. 执行以下命令移除 `asdf` 所有配置文件：

```shell:no-line-numbers
rm -rf $HOME/.tool-versions $HOME/.asdfrc
```

:::

::: details ZSH & Git

1. 在 `~/.zshrc` 配置文件中移除生效 `asdf.sh` 和补全功能的行：

```shell
. $HOME/.asdf/asdf.sh
# ...
fpath=(${ASDF_DIR}/completions $fpath)
autoload -Uz compinit
compinit
```

**或者** ZSH 框架插件（如果用了的话）

2. 移除 `$HOME/.asdf` 目录：

```shell:no-line-numbers
rm -rf ${ASDF_DATA_DIR:-$HOME/.asdf}
```

3. 执行以下命令移除 `asdf` 所有配置文件：

```shell:no-line-numbers
rm -rf $HOME/.tool-versions $HOME/.asdfrc
```

:::

::: details ZSH & Homebrew

1. 在 `~/.zshrc` 配置文件中移除生效 `asdf.sh` 的行：

```shell
. $(brew --prefix asdf)/libexec/asdf.sh
```

2. 用包管理器卸载：

```shell:no-line-numbers
brew uninstall asdf --force && brew autoremove
```

3. 执行以下命令移除 `asdf` 所有配置文件：

```shell:no-line-numbers
rm -rf $HOME/.tool-versions $HOME/.asdfrc
```

:::

::: details ZSH & Pacman

1. 在 `~/.zshrc` 配置文件中移除生效 `asdf.sh` 的行：

```shell
. /opt/asdf-vm/asdf.sh
```

2. 用包管理器卸载：

```shell:no-line-numbers
pacman -Rs asdf-vm
```

3. 移除 `$HOME/.asdf` 目录

```shell:no-line-numbers
rm -rf ${ASDF_DATA_DIR:-$HOME/.asdf}
```

4. 执行以下命令移除 `asdf` 所有配置文件：

```shell:no-line-numbers
rm -rf $HOME/.tool-versions $HOME/.asdfrc
```

:::

恭喜你完成了 🎉
