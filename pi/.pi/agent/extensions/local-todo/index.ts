import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { StringEnum } from "@earendil-works/pi-ai";

type Status = "pending" | "in_progress" | "completed" | "deleted";
type Task = { id: number; subject: string; description?: string; activeForm?: string; status: Status; blockedBy: number[]; owner?: string; metadata?: Record<string, unknown>; createdAt: number; updatedAt: number };
const statuses = ["pending", "in_progress", "completed", "deleted"] as const;
let tasks: Task[] = [];
let nextId = 1;

function visible(includeDeleted?: boolean) { return includeDeleted ? tasks : tasks.filter((t) => t.status !== "deleted"); }
function find(id?: number) { return tasks.find((t) => t.id === id); }
function snapshot(pi: ExtensionAPI) { pi.appendEntry("local-todo-state", { tasks, nextId }); }
function restore(ctx: any) {
  tasks = []; nextId = 1;
  for (const e of ctx.sessionManager.getEntries()) if (e.type === "custom" && e.customType === "local-todo-state") {
    const d = e.data as { tasks?: Task[]; nextId?: number };
    tasks = Array.isArray(d.tasks) ? d.tasks : [];
    nextId = typeof d.nextId === "number" ? d.nextId : Math.max(1, ...tasks.map((t) => t.id + 1));
  }
}
function hasCycle(id: number, deps: number[], seen = new Set<number>()): boolean {
  for (const dep of deps) {
    if (dep === id) return true;
    if (seen.has(dep)) continue;
    seen.add(dep);
    const t = find(dep);
    if (t && hasCycle(id, t.blockedBy, seen)) return true;
  }
  return false;
}
function setWidget(ctx: any) {
  const lines = visible(false).filter((t) => t.status !== "completed").map((t) => `${t.status === "in_progress" ? "◐" : "○"} #${t.id} ${t.activeForm ?? t.subject}`);
  ctx.ui.setWidget("local-todos", lines.length ? ["Todos", ...lines.slice(0, 8)] : []);
}

export default function localTodo(pi: ExtensionAPI) {
  pi.on("session_start", (_e, ctx) => { restore(ctx); if (ctx.hasUI) setWidget(ctx); });
  pi.on("session_compact", (_e, ctx) => { restore(ctx); if (ctx.hasUI) setWidget(ctx); });
  pi.on("session_tree", (_e, ctx) => { restore(ctx); if (ctx.hasUI) setWidget(ctx); });

  pi.registerTool({
    name: "todo",
    label: "Todo",
    description: "Manage a task list for tracking multi-step progress.",
    promptSnippet: "Manage a task list to track multi-step progress",
    promptGuidelines: [
      "Use todo for complex work with 3+ steps, user task lists, or new instruction sets; skip trivial tasks.",
      "When starting work, mark exactly one task in_progress before work. Mark completed immediately when done.",
      "Never mark completed if tests fail or implementation partial.",
      "Use blockedBy for dependencies; cycles rejected.",
    ],
    parameters: Type.Object({
      action: StringEnum(["create", "update", "list", "get", "delete", "clear"] as const),
      id: Type.Optional(Type.Number()),
      subject: Type.Optional(Type.String()),
      description: Type.Optional(Type.String()),
      activeForm: Type.Optional(Type.String()),
      status: Type.Optional(StringEnum([...statuses])),
      blockedBy: Type.Optional(Type.Array(Type.Number())),
      addBlockedBy: Type.Optional(Type.Array(Type.Number())),
      removeBlockedBy: Type.Optional(Type.Array(Type.Number())),
      owner: Type.Optional(Type.String()),
      metadata: Type.Optional(Type.Record(Type.String(), Type.Unknown())),
      includeDeleted: Type.Optional(Type.Boolean()),
    }),
    async execute(_id, p: any, _signal, _update, ctx) {
      const now = Date.now();
      let out: unknown;
      if (p.action === "create") {
        if (!p.subject) throw new Error("subject required");
        const task: Task = { id: nextId++, subject: p.subject, description: p.description, activeForm: p.activeForm, status: p.status ?? "pending", blockedBy: p.blockedBy ?? [], owner: p.owner, metadata: p.metadata, createdAt: now, updatedAt: now };
        if (hasCycle(task.id, task.blockedBy)) throw new Error("blockedBy cycle rejected");
        tasks.push(task); out = task;
      } else if (p.action === "update") {
        const task = find(p.id); if (!task) throw new Error(`task not found: ${p.id}`);
        for (const k of ["subject", "description", "activeForm", "status", "owner"] as const) if (p[k] !== undefined) (task as any)[k] = p[k];
        if (p.metadata) task.metadata = { ...(task.metadata ?? {}), ...p.metadata };
        if (p.addBlockedBy) task.blockedBy = [...new Set([...task.blockedBy, ...p.addBlockedBy])];
        if (p.removeBlockedBy) task.blockedBy = task.blockedBy.filter((id) => !p.removeBlockedBy.includes(id));
        if (hasCycle(task.id, task.blockedBy)) throw new Error("blockedBy cycle rejected");
        task.updatedAt = now; out = task;
      } else if (p.action === "delete") { const task = find(p.id); if (!task) throw new Error(`task not found: ${p.id}`); task.status = "deleted"; task.updatedAt = now; out = task;
      } else if (p.action === "get") { out = find(p.id);
      } else if (p.action === "clear") { tasks = []; nextId = 1; out = [];
      } else { out = visible(p.includeDeleted).filter((t) => !p.status || t.status === p.status); }
      snapshot(pi); if (ctx.hasUI) setWidget(ctx);
      return { content: [{ type: "text", text: JSON.stringify(out, null, 2) }], details: { tasks, nextId } };
    },
  });

  pi.registerCommand("todos", { description: "Show local todos", handler: async (_args, ctx) => ctx.ui.notify(JSON.stringify(visible(false), null, 2), "info") });
}
