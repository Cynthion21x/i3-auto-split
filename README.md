# I3 Auto Split

A simple and lightweight haskell project that automatically toggles between horizontal
and vertical splits for you in an alternating pattern.

# Features

- Its easy to install
- Its made in haskell :D
- Command line configuration

# Installation

You can build the code from source or just download a release.

### Build from source

Prerequisites

- Stack for Haskell
- I3 (obviously)

1. Clone the repository

   ```
   git clone https://github.com/cynthion21x/i3-auto-split.git
   cd i3-auto-split
   ```
   
2. Build the repository

   ```
   stack build
   ```

3. Install the executable

   ```
   stack install
   ```

   You may get a warning saying `~/.local/bin` is not in your path. If not you can easily fix this by adding `export PATH="$HOME/.local/bin:$PATH"` to your `.bashrc`

# Usage

If you have added it to your path you can just add
```
exec --no-startup-id i3-auto-split
```
To your i3 config otherwise if you downloaded it add
```
exec --no-startup-id downloadPath/i3-auto-split
```

You can add some command line arguments to configure how it works.

Verbose mode
```
i3-auto-split -v
```

Ignore specific windows (usefull for floating windows)
```
i3-auto-split -i xfce4-notifyd,dunst,kitty
```

Thread sleep time (how often the main thread of the program wakes up)
```
i3-auto-split -t 1000000000
```

You can easilly put lots of these in your i3 config like go
```
exec --no-startup-id downloadPath/i3-auto-split -i xfce4-notifyd,dunst,kitty -t 1000000000
```

Now  when you restart your pc it should be up and running easy as that!

# Preview

![demo](https://github.com/user-attachments/assets/71216ccf-38c8-4e7b-abb1-f3a391e456ff)

