# 🐹 Vim-Go Development Cheat Sheet

This document tracks the essential shortcuts for Go development in this environment.

## 🚀 The "Big Three" (Navigation)
| Key | Action | Description |
|-----|--------|-------------|
| **`gd`** | **G**o **D**efinition | Jump to where the symbol is defined. |
| **`Ctrl-o`** | Jump Back | Return to where you were before `gd`. |
| **`\\`** | Toggle Files | Instantly switch between the last two files. |

## 🛠 Go Development (`vim-go`)
| Key | Action | Description |
|-----|--------|-------------|
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
| **`\f`** | **F**ind | Search for text strings inside all files (Grep). |
| **`\b`** | **B**uffers | List currently open files. |
| **`\h`** | **H**istory | List recently opened files (MRU). |

## 🧭 Window & History Navigation
| Key | Action | Description |
|-----|--------|-------------|
| **`[b`** | Prev Buffer | Cycle to the previous open file. |
| **`]b`** | Next Buffer | Cycle to the next open file. |
| **`\n`** | Next Result | Jump to next error or caller in Quickfix list. |
| **`\p`** | Prev Result | Jump to previous error or caller in Quickfix list. |
| **`\q`** | **Q**uit List | Close the bottom Quickfix/Results window. |

---
*Tip: The `\` key is your **Leader** key. Press it quickly followed by the next letter.*
