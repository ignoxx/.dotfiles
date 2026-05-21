import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const levels = ["off", "full", "ultra", "micro"] as const;
type Level = (typeof levels)[number];

const prompt = `IMPORTANT: You are in CAVEMAN MODE. Respond terse like smart caveman. All technical substance stay. Only fluff die.

Rules:
- Drop articles (a/an/the), filler (just/really/basically/actually/simply), pleasantries, hedging
- Fragments OK. Short synonyms preferred. Technical terms exact
- Code blocks unchanged. Errors quoted exact
- Pattern: [thing] [action] [reason]. [next step].

Bad: "Sure! I'd be happy to help you with that. The issue you're experiencing is likely caused by..."
Good: "Bug in auth middleware. Token expiry check use \`<\` not \`<=\`. Fix:"

Abbreviate (DB/auth/config/req/res/fn/impl), strip conjunctions, arrows for causality (X → Y).
Example: "Inline obj prop → new ref → re-render. \`useMemo\`."

Auto-clarity: drop caveman for security warnings, irreversible action confirmations, or when user is confused. Resume after.
Boundaries: write normal code. Only compress explanations. "stop caveman" or "normal mode" reverts.`;

const micro = `# Token efficiency
Respond like smart caveman. Cut filler, keep technical substance. Code unchanged. Errors quoted exact.`;

export default function localCaveman(pi: ExtensionAPI) {
  let level: Level = "ultra";

  pi.on("session_start", (_event, ctx) => {
    for (const entry of ctx.sessionManager.getEntries()) {
      if (entry.type === "custom" && entry.customType === "local-caveman-level") {
        const next = (entry.data as { level?: Level })?.level;
        if (next && levels.includes(next)) level = next;
      }
    }
    ctx.ui.setStatus("caveman", level === "off" ? "" : `🔥 caveman ${level}`);
  });

  pi.registerCommand("caveman", {
    description: "Toggle local caveman mode. Args: off|stop|full|ultra|micro",
    getArgumentCompletions(prefix) {
      const p = prefix.trim().toLowerCase();
      return [...levels, "stop"].filter((v) => v.startsWith(p)).map((value) => ({ value, label: value })) || null;
    },
    handler: async (args, ctx) => {
      const arg = args.trim().toLowerCase();
      if (!arg) level = level === "off" ? "ultra" : "off";
      else if (arg === "stop") level = "off";
      else if (levels.includes(arg as Level)) level = arg as Level;
      else return ctx.ui.notify(`Unknown caveman level: ${arg}`, "error");
      pi.appendEntry("local-caveman-level", { level });
      ctx.ui.setStatus("caveman", level === "off" ? "" : `🔥 caveman ${level}`);
      ctx.ui.notify(level === "off" ? "Caveman off." : `Caveman ${level}.`, "info");
    },
  });

  pi.on("before_agent_start", (event) => {
    if (level === "off") return;
    return { systemPrompt: `${event.systemPrompt}\n\n${level === "micro" ? micro : prompt}` };
  });
}
