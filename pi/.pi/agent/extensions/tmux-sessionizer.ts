/**
 * Tmux Sessionizer Extension
 *
 * Binds Ctrl+S to run the tmux-sessionizer script, giving you quick
 * project/session switching from anywhere inside Pi.
 *
 * Checks these locations (in order):
 *   ~/.local/bin/tmux-sessionizer
 *   ~/.dotfiles/tmux/tmux-sessionizer
 *   ~/tmux-sessionizer
 *
 * When Ctrl+S is pressed, Pi suspends its TUI, runs the sessionizer
 * (which uses fzf to pick a project dir and switches to a tmux session),
 * then restores the TUI when done.
 */

import { spawnSync } from "node:child_process";
import { accessSync, constants } from "node:fs";
import { homedir } from "node:os";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const SESSIONIZER_CANDIDATES = [
	`${homedir()}/.local/bin/tmux-sessionizer`,
	`${homedir()}/.dotfiles/tmux/tmux-sessionizer`,
	`${homedir()}/tmux-sessionizer`,
];

function findSessionizer(): string | null {
	for (const path of SESSIONIZER_CANDIDATES) {
		try {
			accessSync(path, constants.X_OK);
			return path;
		} catch {
			// try next
		}
	}
	return null;
}

export default function (pi: ExtensionAPI) {
	pi.registerShortcut("ctrl+s", {
		description: "Run tmux sessionizer",
		handler: async (ctx) => {
			const sessionizer = findSessionizer();
			if (!sessionizer) {
				ctx.ui.notify("tmux-sessionizer: script not found", "error");
				return;
			}

			if (!ctx.hasUI) {
				// Non-interactive mode — won't show fzf UI but still try
				spawnSync(sessionizer, [], { stdio: "inherit", env: process.env });
				return;
			}

			// Temporarily stop the TUI so the interactive script (fzf, tmux)
			// gets full terminal access, then restore when done.
			await ctx.ui.custom<void>((tui, _theme, _kb, done) => {
				tui.stop();
				process.stdout.write("\x1b[2J\x1b[H");

				spawnSync(sessionizer, [], { stdio: "inherit", env: process.env });

				tui.start();
				tui.requestRender(true);
				done(undefined);

				return { render: () => [], invalidate: () => {} };
			});
		},
	});
}
