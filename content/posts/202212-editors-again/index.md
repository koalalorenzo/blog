---
title: "I said goodbye to vscode and switched to Helix"
date: 2022-12-28T10:42:25+01:00
tags:
  - editor
  - 
---
I recently switched from Visual Studio Code (VS Code) to Helix as my primary
text editor. One of the main reasons for the switch was that I wanted a more
efficient and powerful modal editor for working with Go, Terraform, YAML, and
other languages and tools. I also appreciated the lightweight and efficient
design of Helix. In this post, I will discuss my experience with the switch and
the adjustments I made to make Helix a better fit for my daily work.

<!--more-->

## My reasons to switch
One of the main reasons I switched to Helix was because I was looking for a more
lightweight and efficient text editor. While VS Code is a powerful and
feature-rich editor, it can be resource-intensive, especially when editing large
files or working on a system with limited resources. This is probably due to
Electron, lots of JavaScript, and the fact that I had many plugins installed
that I didn't use regularly.

In contrast, [Helix](http://helix-editor.com/) is written in Rust, and it is a
lightweight and performant editor that has not caused any significant
performance issues for me. It offers a good balance of power and efficiency, and
I have been happy with the switch.

## All you need is pipe!
To me, one of the standout features of Helix is its ability to pipe selected
lines and pass them as input to any command, and then replace the selected lines
with the output of the command. This is a powerful and efficient way to perform
common tasks, such as formatting text or running code snippets.

For example, let's say I have a file with some unformatted text that I want to
wrap to fit within the 80th column.  I can use the fmt command to do this
automatically. First, I would select the lines of text that I intend to format,
and then I would use the `|` command to run `fmt -w 80` on the selected lines.
The output would then replace the selected lines, effectively formatting the
text to fit within the 80th column.:q

{{< figure src="pipe.webp" class="big noborder" >}}

Overall, the piping feature in Helix is a great way to automate common tasks and
save time when working with large files or performing repetitive tasks sorting
with `sort`, filtering with `grep` or finding unique lines with `uniq`. :smirk:

_Really_... You can use **any command** that follows the 
[unix philosophy](https://en.wikipedia.org/wiki/Unix_philosophy)! isn't that 
great already?

## Customizing Helix for a Better Workflow
At first, I wasn't sure if I needed to customize Helix, as it seemed to work
well out of the box. However, after spending some time with the editor and
exploring the various customization options, I realized that making a few small
adjustments could make a big difference in my workflow.

For example, selecting 
[a color scheme](https://github.com/helix-editor/helix/wiki/Themes) that works
well for me has made it easier to read and work with code, and adding vertical
rules at the 80th column has helped me to keep my code and documentation aligned
and easy to read.

```toml
theme = "monokai_pro_spectrum"
[editor]
rulers = [80, 120]
mouse = true
```

These small changes may seem insignificant, but they have made a noticeable
difference in my productivity and overall enjoyment of the editor.

Something more useful was changing the behavior of the clipboard to work
seamlessly when using copy-paste. This saved me a lot of time when working with
large blocks of text from a command line.

```toml
[keys.normal]
# Use system clipboard
y = "yank_main_selection_to_clipboard"
p = "paste_clipboard_before"
```

Overall, I have found that customizing Helix to suit my specific needs and
preferences has helped me to work more efficiently and effectively. While it may
not be necessary for everyone, I would highly recommend taking some time to
explore the customization options and see if they can help you to improve your
workflow.

If you need some inspiration, you can check
[my configuration here](https://gitlab.com/-/snippets/2476731).

## Auto complete, linting, formatting and more
One of the things that has really improved my workflow in Helix is the use of
language servers. These servers provide a range of features, such as formatting,
linting, auto complete, and references that can help to write code as a full 
IDE.

To install some of the language servers that I use every day for Helix, on macOS
you can use the following command:

```bash
# For Terraform (HCL), Bash, Generic YAML, 
# Docker, Docker compose and Ansible
brew install terraform-ls bash-language-server \
             yaml-language-server docker-ls \
             ansible-language-server

# For HTML, json, css, javascript and typescript
npm i -g vscode-langservers-extracted typescript typescript-language-server

# Go official language server
go install golang.org/x/tools/gopls@latest
```

You can check [more language servers here](https://github.com/helix-editor/helix/wiki/How-to-install-the-default-language-servers)
and it is possible to check how the various languages are supported by running:

```bash
hx --health
```

## Finding my way to files (fzf + ripgrep)
The default file browser in Helix (`helix .`) is missing the ability to filter
files by their content, rather than just their names. While the default file
browser does use fuzzy search, it only searches for matches in the file names,
which can be limiting if you are looking for a specific piece of text within a
large number of files.

To address this issue, I modified a bash function[^copy-pasta] that uses
[fzf](https://github.com/junegunn/fzf) and 
[ripgrep](https://github.com/BurntSushi/ripgrep) to filter files by their
content. This has been a game-changer for me, as it has made it much easier to
find specific pieces of text within many files. In addition, I modified the
script to support _opening multiple files at once_ (with `vsplit`), which has
saved me a lot of time when working with related files.

This is the code that I have added to my `~/.bash_profile` or equivalent:

```bash
# Helix Search
hxs() {
	RG_PREFIX="rg -i --files-with-matches"
	local files
	files="$(
		FZF_DEFAULT_COMMAND_DEFAULT_COMMAND="$RG_PREFIX '$1'" \
			fzf --multi 3 --print0 --sort --preview="[[ ! -z {} ]] && rg --pretty --context 5 {q} {}" \
				--phony -i -q "$1" \
				--bind "change:reload:$RG_PREFIX {q}" \
				--preview-window="70%:wrap" \
				--bind 'ctrl-a:select-all'
	)"
	[[ "$files" ]] && hx --vsplit $(echo $files | tr \\0 " ")
}
```

[^copy-pasta]: I don't remember where I found it, but I had to modify it. If you
               know the original author please let me know and I will mention 
               it! :sweat_smile:
