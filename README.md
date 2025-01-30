# Emacs estate-mode

Estate mode is a minor mode for GNU Emacs for modal editing.

## estate.el

If you merely `(require 'estate)`, you get a blank slate DIY modal editing system with no modes (or states in estate parlance, since Emacs uses the word “mode” for something else).
It is similar to `evil-core` from [Evil](https://github.com/emacs-evil/evil), but much smaller, with fewer bells and whistles.

Estate allows an arbitrary number of states (modes).
Define states with `estate-define-state`.
If you write `(estate-define-state excitement tubular-keymap)`, you will define a state of excitement that comes with `estate-excitement-state-keymap` which inherits from `tubular-keymap`, `estate-excitement-state-buffer-local-keymap` which is initially null, `estate-excitement-state-enter-hook`, `estate-excitement-state-exit-hook`, and `estate-excitement-state` to activate the state.
Change states with `estate-activate-state`, giving the state's symbol passed to `estate-define-state`, or (equivalently) by calling the defined activation function.
If your state wants some extra setup, you can wrap `estate-activate-state` with your own function or use the hooks.

## estate-default-states.el

If you `(require 'estate-default-states)`, you get some pre-defined states that are fairly similar to Vim or Evil-mode.

* `estate-motion-state`, whose keymap is inhibited so that unbound keys are ignored rather than performing self-insert.
* `estate-normal-state`, whose keymap inherits from motion-state.  This is the intended default state for most cases, like in vim.
* `estate-insert-state`, whose keymap is NOT inhibited, so any unbound key is handled by the global keymap.  Hooks for insert state group changes into a single unit for undo.
* `estate-visual-state`, which has hooks so that it is activated when the region is activated, and vice versa.  Its keymap inherits from normal-state.  It assumes that you use `transitive-mark-mode`.
* `estate-pager-state`, whose keymap inherits from motion-state.  The buffer is set to read-only when pager-state is active.

IMPORTANT: by default the key maps for these modes have NO KEY BINDINGS.  If you activate estate-mode without defining key bindings (or using some other package that defines them), you will be stuck.


## Why does this package exist?

I used [evil-mode](https://github.com/emacs-evil/evil) for a decade.
It's great.
Evil-mode is really impressive.
It is super faithful to Vim while still making it better in many significant ways.
The most significant, of course, is bringing it to emacs with its pervasive programmability.
But even if you don't program anything about it, don't add third party packages, only use the default states and key bindings, etc, there are a few features like visual block mode that it improves!

But there are some things that I didn't like:

* Evil-mode comes very pre-configured, and the first thing my configuration did was try to eliminate most of the default settings, including key maps.
* Evil-mode is fairly big and complicated.  It implements a faithful emulation of Vim, which is complicated.  At various times I've wanted to hack around things that evil-mode does, and found that it wouldn't be clear what pieces do without reading a bunch of code, which I typically didn't want to do.  Estate is small.  This means less featureful, yes, but I didn't use most of evil-mode's features.
* Evil-mode is a faithful emulation of Vim.  Vim (and Vi) have a ton of great ideas.  But they also have some questionable or bad ideas that evil-mode carries forward, that I want to shed.
* Evil-mode is more monolithic than I want.  There are separate pieces that can be used individually, but they still typically carry various pieces of Vim that I don't like and don't want anymore.
* One important detail, to me, is that Vim and Evil-mode use on-character addressing for non-insert modes, which I view as a mistake.  It's a constant minor annoyance when integrating with packages that are not intended specifically to work with evil-mode.
* There are other modal editing packages for emacs besides evil!  Why didn't I use them?  [Modalka](https://github.com/mrkkrp/modalka) and [ryo-modal](https://github.com/Kungsgeten/ryo-modal) are both DIY systems, but they each support only one extra mode besides the default emacs mode.  I wanted arbitrarily many modes.  All of the other modal editing packages that I've seen define some specific opinionated key binding on top of the modal editing features.  I am building a different opinionated modal editing system, so I don't want to pull in that stuff.

So I wrote estate-mode to be a small package that provides modal editing in order to pair it with other things I'm building.
But it could also be used to just write different modes to use basic emacs functions from.
Do what you want with it.

## You mention that it's optionally part of a bigger system?

Yes, you can pair estate-mode with some other packages that I've written to have written to have a complete modal text editor.
TODO - I've mostly written them, and am in the process of packaging them...  Link and explain later.

## What changes might happen in the future?

I might add visual-line mode and/or visual-block/rectangle mode.
Maybe.
Visual-block mode has a specific workflow that I'm used to for doing a couple of things, but half of that is covered by what emacs does with rectangles out-of-the-box and doesn't need a state for, and the other half I may decide to solve in a different way.
Visual-line mode is really convenient, though, and I've missed it a lot more than visual-block mode.
