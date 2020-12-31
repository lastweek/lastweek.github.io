# Dot Configs

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Dec 17, 2020| started |

Like many others, I maintain my own dot-file repo: https://github.com/lastweek/dot-home.
It helps me setup the terminal whenever I start using a new machine.

I'm a heavy terminal user. For whatever coding task (e.g., kernel, RDMA, FPGA, scala, C),
I use terminal. I sometimes use terminal to write paper as well.

There are several important tools I rely on: zsh, git, neovim, and tmux.
And I'm grateful for folks working on these tools and their plugins.

- For zsh, I use oh-my-zsh.
- For git, I use [git alias](https://github.com/GitAlias/gitalias).
- For tmux, I use [tpm](https://github.com/tmux-plugins). I used to cook status line myself, but I have switched to powerline.
- For nvim, I use [vundle](https://github.com/VundleVim/Vundle.vim). And I have several cooked keys.

## VIM

I'm using several popular tools: NERD Tree, NERD commenter, GitGutter, and Tagbar.

I created the following mapped keys so that I could invoke them quite easily.
Basically I press `\` first, and then press `t`, or `f`, or `g`.
```
map \l :TagbarToggle<Enter>    => to toggle tagbar list
map \f :NERDTreeToggle<CR>     => to toggle nerd file tree
map \g :GitGutterLineHighlightsToggle<Enter> :GitGutterSignsToggle<Enter>   => to highlight git difference
```

Besides, I have several extra syntax files, for C, ASM, scala, and verilog.
I started this when I was hacking linux kernel.
It has so many new awesome macros (e.g., `BUG_ON`, `for_each_cpu`) and I want to
diffrentiate them from normal functions. So I added those [`after/syntax`](https://github.com/lastweek/dot-home/tree/master/.vim/after/syntax) files.

## Colorful Man Pages

This is one thing I highly recommend.
It was always a pain reading man pages,
not until I found this trick.
We can, in fact, redirect man outputs into vim,
which in turn can present the text in a colorway.

Add these to your shell dotconfig:
```bash
vman() { man $* | col -b | vim -c 'set ft=man nomod nolist' -; }    
alias man="vman"
```

## Git

For git, I'm using [git alias](https://github.com/GitAlias/gitalias)
and a tool call tig.

The `git alias` project has quite a lot shortcuts.
Those are my most used ones:
```bash
g s

g l
g ll
g lll

g d
g dc
g ds
```
