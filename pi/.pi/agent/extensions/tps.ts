/**
 * Output throughput for each assistant response, excluding startup and tool time.
 * Uses provider-reported output usage (including reasoning where reported).
 * Local delta timing is approximate; buffered/hidden output cannot be timed reliably.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	let firstDelta: number | undefined;
	let lastDelta: number | undefined;
	let deltaCount = 0;
	let estimatedCharacters = 0;
	let lastLiveUpdate: number | undefined;

	function reset() {
		firstDelta = undefined;
		lastDelta = undefined;
		deltaCount = 0;
		estimatedCharacters = 0;
		lastLiveUpdate = undefined;
	}

	pi.on("session_start", (_event, ctx) => {
		reset();
		ctx.ui.setStatus("tps", undefined);
	});

	pi.on("turn_start", () => {
		reset();
	});

	pi.on("message_start", (event) => {
		if (event.message.role !== "assistant") return;
		// Keep previous throughput visible until a new live estimate replaces it.
		reset();
	});

	pi.on("message_update", (event, ctx) => {
		if (event.message.role !== "assistant") return;
		const update = event.assistantMessageEvent;
		if (
			(update.type !== "text_delta" &&
				update.type !== "thinking_delta" &&
				update.type !== "toolcall_delta") ||
			!update.delta
		) return;

		const now = performance.now();
		firstDelta ??= now;
		lastDelta = now;
		deltaCount++;
		// First chunk arrived before our clock started; exclude it from live estimate.
		if (deltaCount === 1) return;
		estimatedCharacters += update.delta.length;
		const seconds = (now - firstDelta) / 1000;
		if (seconds < 0.1 || (lastLiveUpdate !== undefined && now - lastLiveUpdate < 250)) return;
		lastLiveUpdate = now;
		// Rough text heuristic, not a tokenizer. Final usage replaces this estimate.
		const tps = estimatedCharacters / 4 / seconds;
		ctx.ui.setStatus("tps", ctx.ui.theme.fg("dim", `~${tps.toFixed(0)} tok/s`));
	});

	pi.on("message_end", (event, ctx) => {
		if (event.message.role !== "assistant") return;
		const tokens = event.message.usage.output;
		const seconds = firstDelta !== undefined && lastDelta !== undefined
			? (lastDelta - firstDelta) / 1000
			: 0;

		// A single chunk or tiny span cannot give meaningful generation throughput.
		if (event.message.stopReason === "error" || event.message.stopReason === "aborted") {
			ctx.ui.setStatus("tps", undefined);
		} else if (tokens > 0 && deltaCount > 1 && seconds >= 0.1) {
			ctx.ui.setStatus(
				"tps",
				ctx.ui.theme.fg("success", `${(tokens / seconds).toFixed(1)} tok/s`) +
				ctx.ui.theme.fg("dim", ` (${tokens} tokens in ${seconds.toFixed(1)}s)`),
			);
		} else {
			ctx.ui.setStatus("tps", tokens > 0
				? ctx.ui.theme.fg("dim", `${tokens} tokens · tok/s unavailable`)
				: undefined);
		}
		reset();
	});
}
