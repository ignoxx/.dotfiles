# Local changes

Based on `andrewchng/herdr-sessionizer` v0.6.1.

`src/sessionizer/sessionizer.ts` uses one deterministic project picker:

- selecting a project whose normalized path or generated label matches an open Herdr workspace focuses it
- selecting any other project creates, lays out, and focuses a workspace
- Escape only cancels; it is not a hidden "create" mode

Associated behavior is covered by `src/sessionizer/sessionizer.test.ts`.

## Dotfiles integration

Plugin source lives inside the `herdr` Stow package. `run` lazily installs runtime dependencies and launches the picker directly in a Herdr custom popup, so a new machine needs no `herdr plugin link` registry setup after `stow herdr`.
