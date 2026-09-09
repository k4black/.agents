/**
 * OpenCode plugin: block destructive commands before bash tool execution.
 */
import { execFileSync } from "node:child_process";
import * as path from "node:path";
import * as fs from "node:fs";

export default {
  "tool.execute.before": async (input, output) => {
    if (input.tool !== "bash" && input.tool !== "shell") {
      return;
    }

    const command = output.args?.command || output.args?.cmd;
    if (!command || typeof command !== "string") {
      return;
    }

    const candidates = [
      path.resolve(process.env.HOME || "", "Projects/personal/.agents/permissions/check_destructive.py"),
      path.resolve(process.env.HOME || "", ".agents/permissions/check_destructive.py"),
    ];

    const scriptPath = candidates.find((p) => fs.existsSync(p));
    if (!scriptPath) {
      return;
    }

    try {
      execFileSync("python3", [scriptPath, command], {
        stdio: ["ignore", "pipe", "pipe"],
      });
    } catch (err) {
      if (err.status === 2) {
        const reason = err.stderr ? err.stderr.toString().trim() : "Destructive command blocked by policy";
        throw new Error(reason);
      }
    }
  },
};
