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

