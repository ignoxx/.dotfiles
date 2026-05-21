import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const dangerousBash = [
  /\brm\s+-[^\n;|&]*r[f]?\b/,
  /\bsudo\b/,
  /\bcurl\b.*\|\s*(sh|bash|zsh)\b/,
  /\bwget\b.*\|\s*(sh|bash|zsh)\b/,
  /\bchmod\s+777\b/,
  /\bchown\b.*\s+\//,
  /\bdd\s+.*of=\/dev\//,
  /\bmkfs\b/,
  /\bshutdown\b|\breboot\b/,
];
const protectedPath = /(^|\/)\.env($|\.)|(^|\/)\.ssh(\/|$)|(^|\/)\.gnupg(\/|$)|(^|\/)node_modules(\/|$)|(^|\/)\.git(\/|$)|(^|\/)auth\.json$/;

function pathFromInput(input: unknown): string[] {
  const obj = input as Record<string, unknown>;
  return [obj.path, obj.file, obj.target].filter((v): v is string => typeof v === "string");
}

export default function localGuardrails(pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName === "bash") {
      const command = String((event.input as { command?: unknown }).command ?? "");
      const hit = dangerousBash.find((r) => r.test(command));
      if (hit) {
        const ok = await ctx.ui.confirm("Guardrail", `Dangerous shell command matches ${hit}. Allow?`);
        if (!ok) return { block: true, reason: `Blocked dangerous shell command: ${hit}` };
      }
    }

    if (["read", "write", "edit"].includes(event.toolName)) {
      for (const p of pathFromInput(event.input)) {
        if (protectedPath.test(p)) return { block: true, reason: `Blocked ${event.toolName} on protected path: ${p}` };
      }
    }
  });

  pi.registerCommand("guardrails", {
    description: "Show local guardrails summary",
    handler: async (_args, ctx) => ctx.ui.notify("Local guardrails active: dangerous bash confirmation; protected path write block (.env, .ssh, .gnupg, node_modules, .git, auth.json).", "info"),
  });
}
