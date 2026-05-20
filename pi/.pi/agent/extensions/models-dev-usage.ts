/**
 * Models.dev Usage Reporter
 *
 * Tracks Pi usage (cost, tokens, models) and provides daily/weekly/monthly
 * reports with per-model breakdowns.
 *
 * Usage:
 *   /usage today     - Show today's usage
 *   /usage week      - Show this week's usage
 *   /usage month     - Show this month's usage
 *   /usage all       - Show all recorded usage
 *   /usage           - Same as today
 *
 * Data is stored in ~/.pi/agent/usage-data.jsonl and persists across sessions.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { readFile, appendFile, mkdir } from "node:fs/promises";
import { existsSync } from "node:fs";
import { join } from "node:path";
import { homedir } from "node:os";

// ─── Types ───────────────────────────────────────────────────────────────────

interface UsageRecord {
	timestamp: number;        // ms epoch
	provider: string;
	model: string;
	inputTokens: number;
	outputTokens: number;
	cacheReadTokens: number;
	cacheWriteTokens: number;
	totalTokens: number;
	costInput: number;
	costOutput: number;
	costCacheRead: number;
	costCacheWrite: number;
	costTotal: number;
	stopReason: string;
}

interface UsageSummary {
	totalCost: number;
	totalTokens: number;
	totalInputTokens: number;
	totalOutputTokens: number;
	totalCacheReadTokens: number;
	totalCacheWriteTokens: number;
	callCount: number;
	models: Record<string, {
		model: string;
		provider: string;
		callCount: number;
		cost: number;
		tokens: number;
		inputTokens: number;
		outputTokens: number;
	}>;
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

const DATA_DIR = join(homedir(), ".pi", "agent");
const DATA_FILE = join(DATA_DIR, "usage-data.jsonl");

function getDataFile(): string {
	return DATA_FILE;
}

async function ensureDataDir() {
	await mkdir(DATA_DIR, { recursive: true });
}

async function appendRecord(record: UsageRecord): Promise<void> {
	await ensureDataDir();
	const line = JSON.stringify(record) + "\n";
	await appendFile(DATA_FILE, line, "utf8");
}

async function readAllRecords(): Promise<UsageRecord[]> {
	if (!existsSync(DATA_FILE)) return [];
	const data = await readFile(DATA_FILE, "utf8");
	const lines = data.trim().split("\n").filter(Boolean);
	return lines.map((line) => JSON.parse(line) as UsageRecord);
}

function getStartOfDay(ts: number): number {
	const d = new Date(ts);
	d.setHours(0, 0, 0, 0);
	return d.getTime();
}

function getStartOfWeek(ts: number): number {
	const d = new Date(ts);
	const day = d.getDay(); // 0=Sun
	const diff = d.getDate() - day + (day === 0 ? -6 : 1); // Monday start
	d.setDate(diff);
	d.setHours(0, 0, 0, 0);
	return d.getTime();
}

function getStartOfMonth(ts: number): number {
	const d = new Date(ts);
	d.setDate(1);
	d.setHours(0, 0, 0, 0);
	return d.getTime();
}

function aggregateRecords(records: UsageRecord[]): UsageSummary {
	const summary: UsageSummary = {
		totalCost: 0,
		totalTokens: 0,
		totalInputTokens: 0,
		totalOutputTokens: 0,
		totalCacheReadTokens: 0,
		totalCacheWriteTokens: 0,
		callCount: records.length,
		models: {},
	};

	for (const r of records) {
		summary.totalCost += r.costTotal;
		summary.totalTokens += r.totalTokens;
		summary.totalInputTokens += r.inputTokens;
		summary.totalOutputTokens += r.outputTokens;
		summary.totalCacheReadTokens += r.cacheReadTokens;
		summary.totalCacheWriteTokens += r.cacheWriteTokens;

		const key = `${r.provider}/${r.model}`;
		if (!summary.models[key]) {
			summary.models[key] = {
				model: r.model,
				provider: r.provider,
				callCount: 0,
				cost: 0,
				tokens: 0,
				inputTokens: 0,
				outputTokens: 0,
			};
		}
		const m = summary.models[key];
		m.callCount++;
		m.cost += r.costTotal;
		m.tokens += r.totalTokens;
		m.inputTokens += r.inputTokens;
		m.outputTokens += r.outputTokens;
	}

	return summary;
}

function formatCost(cost: number): string {
	return `$${cost.toFixed(4)}`;
}

function formatTokens(n: number): string {
	if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1)}M`;
	if (n >= 1_000) return `${(n / 1_000).toFixed(1)}K`;
	return String(n);
}

function formatDate(ts: number): string {
	return new Date(ts).toLocaleDateString("en-US", {
		month: "short",
		day: "numeric",
		hour: "2-digit",
		minute: "2-digit",
	});
}

// ─── Report building ─────────────────────────────────────────────────────────

function buildReport(summary: UsageSummary, periodLabel: string): string {
	const lines: string[] = [];
	const sep = "─".repeat(40);

	lines.push(`╭─── ${periodLabel} Usage Report ───╮`);
	lines.push("");
	lines.push(`  Calls:        ${summary.callCount}`);
	lines.push(`  Total Cost:   ${formatCost(summary.totalCost)}`);
	lines.push(`  Total Tokens: ${formatTokens(summary.totalTokens)}`);
	lines.push(`  Input Tokens: ${formatTokens(summary.totalInputTokens)}`);
	lines.push(`  Output Tokens:${formatTokens(summary.totalOutputTokens)}`);
	lines.push(`  Cache Read:   ${formatTokens(summary.totalCacheReadTokens)}`);
	lines.push(`  Cache Write:  ${formatTokens(summary.totalCacheWriteTokens)}`);
	lines.push("");
	lines.push(`  ${sep}`);
	lines.push("");

	// Sort models by cost descending
	const sorted = Object.values(summary.models).sort((a, b) => b.cost - a.cost);

	for (const m of sorted) {
		lines.push(`  ${m.provider}/${m.model}`);
		lines.push(`    Calls:  ${m.callCount}`);
		lines.push(`    Cost:   ${formatCost(m.cost)}`);
		lines.push(`    Tokens: ${formatTokens(m.tokens)}  (in: ${formatTokens(m.inputTokens)}, out: ${formatTokens(m.outputTokens)})`);
		lines.push("");
	}

	lines.push(`  ${sep}`);
	lines.push(`  Data: ${DATA_FILE}`);

	return lines.join("\n");
}

async function getSummaryForPeriod(
	records: UsageRecord[],
	now: number,
	periodStartFn: (ts: number) => number,
	label: string,
): Promise<string> {
	const start = periodStartFn(now);
	const filtered = records.filter((r) => r.timestamp >= start);
	const summary = aggregateRecords(filtered);
	return buildReport(summary, label);
}

// ─── Extension ───────────────────────────────────────────────────────────────

export default function usageExtension(pi: ExtensionAPI) {
	// ── Track usage on each assistant message ─────────────────────────────────
	pi.on("message_end", async (event, _ctx) => {
		if (event.message.role !== "assistant") return;
		if (!event.message.usage) return;

		const usage = event.message.usage;
		const record: UsageRecord = {
			timestamp: event.message.timestamp ?? Date.now(),
			provider: event.message.provider ?? "",
			model: event.message.model ?? "",
			inputTokens: usage.input ?? 0,
			outputTokens: usage.output ?? 0,
			cacheReadTokens: usage.cacheRead ?? 0,
			cacheWriteTokens: usage.cacheWrite ?? 0,
			totalTokens: usage.totalTokens ?? 0,
			costInput: usage.cost?.input ?? 0,
			costOutput: usage.cost?.output ?? 0,
			costCacheRead: usage.cost?.cacheRead ?? 0,
			costCacheWrite: usage.cost?.cacheWrite ?? 0,
			costTotal: usage.cost?.total ?? 0,
			stopReason: event.message.stopReason ?? "",
		};

		// Fire-and-forget write (don't block message processing)
		appendRecord(record).catch((err) => {
			console.error("[models-dev-usage] Failed to write usage record:", err);
		});
	});

	// ── /usage command ────────────────────────────────────────────────────────
	pi.registerCommand("usage", {
		description: "Show AI usage report (today, week, month, all)",
		getArgumentCompletions: (prefix) => {
			const options = ["today", "week", "month", "all"];
			const filtered = options.filter((o) => o.startsWith(prefix));
			return filtered.length > 0 ? filtered.map((s) => ({ value: s, label: s })) : null;
		},
		handler: async (args, ctx) => {
			const period = (args ?? "").trim().toLowerCase() || "today";
			const now = Date.now();

			let records: UsageRecord[];
			try {
				records = await readAllRecords();
			} catch (err) {
				ctx.ui.notify("Failed to read usage data", "error");
				return;
			}

			if (records.length === 0) {
				ctx.ui.notify("No usage data recorded yet. Start using Pi and check back!", "info");
				return;
			}

			let report: string;
			switch (period) {
				case "today":
					report = await getSummaryForPeriod(records, now, getStartOfDay, "Today");
					break;
				case "week":
					report = await getSummaryForPeriod(records, now, getStartOfWeek, "This Week");
					break;
				case "month":
					report = await getSummaryForPeriod(records, now, getStartOfMonth, "This Month");
					break;
				case "all":
					report = buildReport(aggregateRecords(records), "All Time");
					break;
				default:
					ctx.ui.notify(`Unknown period: ${period}. Use: today, week, month, all`, "warning");
					return;
			}

			// Send as a conversation message so you can scroll normally
			pi.sendMessage({
				customType: "usage-report",
				content: report,
				display: true,
				details: {},
			});
			ctx.ui.notify(`📊 ${report.match(/╭─── (.+?) Usage/)?.[1] ?? period} usage report`, "info");
		},
	});

	// ── Tool for the LLM ─────────────────────────────────────────────────────
	pi.registerTool({
		name: "usage_report",
		label: "Usage Report",
		description: "Get AI usage statistics including cost, tokens, and model breakdown. Period: today, week, month, all.",
		promptSnippet: "Get AI usage statistics for cost, tokens, and model breakdown",
		promptGuidelines: [
			"Use usage_report when the user asks about AI usage, costs, tokens, or model usage statistics.",
		],
		parameters: {
			type: "object",
			properties: {
				period: {
					type: "string",
					description: "Time period: today, week, month, all",
					enum: ["today", "week", "month", "all"],
				},
			},
			required: ["period"],
		},
		async execute(_toolCallId, params, _signal, _onUpdate, _ctx) {
			const period = (params.period as string) ?? "today";
			const now = Date.now();

			let records: UsageRecord[];
			try {
				records = await readAllRecords();
			} catch {
				return {
					content: [{ type: "text", text: "No usage data found yet." }],
					details: {},
				};
			}

			if (records.length === 0) {
				return {
					content: [{ type: "text", text: "No usage data recorded yet." }],
					details: {},
				};
			}

			let report: string;
			switch (period) {
				case "today":
					report = await getSummaryForPeriod(records, now, getStartOfDay, "Today");
					break;
				case "week":
					report = await getSummaryForPeriod(records, now, getStartOfWeek, "This Week");
					break;
				case "month":
					report = await getSummaryForPeriod(records, now, getStartOfMonth, "This Month");
					break;
				case "all":
					report = buildReport(aggregateRecords(records), "All Time");
					break;
				default:
					report = await getSummaryForPeriod(records, now, getStartOfDay, "Today");
			}

			return {
				content: [{ type: "text", text: report }],
				details: {},
			};
		},
	});
}
