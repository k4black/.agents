/**
 * Pi coding agent extension: block destructive commands before bash tool runs.
 */
import { isToolCallEventType } from "@earendil-works/pi-coding-agent";
import { execFileSync } from "node:child_process";
import * as path from "node:path";
import * as fs from "node:fs";

export default function (pi: any) {
  pi.on("tool_call", async (event: any) => {
    if (!isToolCallEventType("bash", event)) {
      return;
    }

    const command = event.input?.command;
    if (!command || typeof command !== "string") {
      return;
    }

    // Resolve check_destructive.sh from repo permissions folder or ~/.dotfiles/.agents
    const candidates = [
      path.resolve(__dirname, "../../permissions/check_destructive.sh"),
      path.resolve(process.env.HOME || "", ".agents/permissions/check_destructive.sh"),
      path.resolve(process.env.HOME || "", "Projects/personal/.agents/permissions/check_destructive.sh"),
    ];

    let scriptPath = candidates.find((p) => fs.existsSync(p));
    if (!scriptPath) {
      return;
    }

    try {
      execFileSync(scriptPath, [command], {
        stdio: ["ignore", "pipe", "pipe"],
      });
    } catch (err: any) {
      if (err.status === 2) {
        const reason = err.stderr ? err.stderr.toString().trim() : "Destructive command blocked by policy";
        return {
          block: true,
          reason,
          terminate: false,
        };
      }
    }
  });
}
