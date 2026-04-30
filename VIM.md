# 🛠️ Vim Development Cheat Sheet

This document tracks the essential shortcuts for Go, Rust, and general development.

## 🚀 The "Big Three" (Navigation)
| Key | Action | Description |
|-----|--------|-------------|
| **`gd`** | **G**o **D**efinition | Jump to where the symbol is defined. |
| **`Ctrl-o`** | Jump Back | Return to where you were before `gd`. |
| **`\ \`** | Toggle Files | Double-Leader: Switch between the last two files. |
| **`Ctrl-l`** | **L**oad / Refresh | Reload from disk, clear search highlights, and redraw. |

## 🛠 Go Development (`vim-go`)
| Key | Action | Description |
|-----|--------|-------------|
| **`F2`** | **R**ename | Rename symbol project-wide (also `\rn`). |
| **`\c`** | **C**allers | List all places that call this function (Quickfix). |
| **`\s`** | **S**ymbols | Fuzzy-search functions/types in the **current file**. |
| **`\S`** | **S**ymbols Dir | Fuzzy-search symbols in the **entire package**. |
| **`\t`** | **T**est | Run tests for the current file. |
| **`\a`** | **A**lternate | Toggle between `file.go` and `file_test.go`. |
| **`\b`** | **B**uild | Compile the current package to check for errors. |
| **`\r`** | **R**un | Run the current package. |

## 🔍 Search & Files (FZF)
| Key | Action | Description |
|-----|--------|-------------|
| **`Ctrl-p`** | **P**roject | Fuzzy search all files in the repository. |
| **`\gs`** | **G**it **S**tatus | Fuzzy search only **modified/new** files. |
| **`\f`** | **F**ind | Search for text strings inside all files (Grep). |
| **`\b`** | **B**uffers | List currently open files. |
| **`\h`** | **H**istory | List recently opened files (MRU). |

## 🌿 Git Operations (GitGutter)
| Key | Action | Description |
|-----|--------|-------------|
| **`]c`** | Next Change | Jump to the next modified hunk. |
| **`[c`** | Prev Change | Jump to the previous modified hunk. |
| **`\hp`** | **H**unk **P**review | Show a diff of the current change in a popup. |
| **`\hu`** | **H**unk **U**ndo | Revert only the current block of code to Git state. |

## 🧭 Window & History Navigation
| Key | Action | Description |
|-----|--------|-------------|
| **`[b`** | Prev Buffer | Cycle to the previous open file. |
| **`]b`** | Next Buffer | Cycle to the next open file. |
| **`\n`** | Next Result | Jump to next error or caller in Quickfix list. |
| **`\p`** | Prev Result | Jump to previous error or caller in Quickfix list. |
| **`\q`** | **Q**uit List | Close the Quickfix AND Hunk Preview windows. |

---
*Tip: The `\` key is your **Leader** key. Press it quickly followed by the next letter.*
