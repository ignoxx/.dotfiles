/**
 * Tokens Per Second Extension
 *
 * Measures model output tokens per second for each turn.
 * Displays in the footer status line — live estimate during streaming,
 * final accurate count at turn end.
 */

import type { AssistantMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

function isAssistant(msg: { role: string }): msg is AssistantMessage {
	return msg.role === "assistant";
}

export default function (pi: ExtensionAPI) {
	let turnStart = 0;
	let chunkCount = 0;

	pi.on("turn_start", () => {
		turnStart = Date.now();
		chunkCount = 0;
	});

	// Live-ish estimate: each streaming update ≈ one chunk
	pi.on("message_update", async (event, ctx) => {
		if (!isAssistant(event.message)) return;
		chunkCount++;

		if (turnStart && chunkCount % 5 === 0) {
			const elapsed = (Date.now() - turnStart) / 1000;
			if (elapsed > 0.3) {
				const tps = (chunkCount / elapsed).toFixed(0);
				ctx.ui.setStatus("tps", ctx.ui.theme.fg("dim", `${tps} tok/s`));
			}
		}
	});

	// Accurate TPS at turn end using actual usage.output
	pi.on("turn_end", async (event, ctx) => {
		const elapsed = (Date.now() - turnStart) / 1000;

		if (isAssistant(event.message) && elapsed > 0.1) {
			const outputTokens = event.message.usage?.output ?? 0;
			const tps = outputTokens > 0
				? (outputTokens / elapsed).toFixed(1)
				: (chunkCount / elapsed).toFixed(0) + "~";

			ctx.ui.setStatus(
				"tps",
				ctx.ui.theme.fg("success", `${tps} tok/s`) +
				ctx.ui.theme.fg("dim", ` (${outputTokens} tokens in ${elapsed.toFixed(1)}s)`),
			);
		} else {
			ctx.ui.setStatus("tps", undefined);
		}

		turnStart = 0;
		chunkCount = 0;
	});
}
