const { defineConfig } = require("cypress");
const http = require("http");
const path = require("path");
const { spawn } = require("child_process");

let serverProcess;

const SERVER_URL = "http://localhost:3000";
const SERVER_START_TIMEOUT_MS = 15000;
const SERVER_POLL_INTERVAL_MS = 250;

function isServerUp(url) {
  return new Promise((resolve) => {
    const req = http.get(url, (res) => {
      res.resume();
      resolve(res.statusCode >= 200 && res.statusCode < 500);
    });
    req.on("error", () => resolve(false));
    req.setTimeout(2000, () => {
      req.destroy();
      resolve(false);
    });
  });
}

async function waitForServer(url, timeoutMs) {
  const start = Date.now();
  while (Date.now() - start < timeoutMs) {
    // eslint-disable-next-line no-await-in-loop
    if (await isServerUp(url)) return;
    // eslint-disable-next-line no-await-in-loop
    await new Promise((r) => setTimeout(r, SERVER_POLL_INTERVAL_MS));
  }
  throw new Error(`Server did not start within ${timeoutMs}ms at ${url}`);
}

async function startServer() {
  if (await isServerUp(SERVER_URL)) return;

  const appPath = path.join(__dirname, "app.js");
  serverProcess = spawn(process.execPath, [appPath], {
    stdio: "inherit",
    env: { ...process.env, PORT: "3000" },
  });

  await waitForServer(SERVER_URL, SERVER_START_TIMEOUT_MS);
}

async function stopServer() {
  if (!serverProcess) return;
  serverProcess.kill("SIGTERM");
  serverProcess = undefined;
}

module.exports = defineConfig({
  reporter: "mochawesome",
  reporterOptions: {
    reportDir: "cypress/reports",
    reportFilename: "mochawesome",
    overwrite: false,
    html: true,
    json: true,
  },
  e2e: {
    setupNodeEvents(on, config) {
      const { plugin } = require("@cypress/grep/plugin");
      plugin(config);
      on("before:run", async () => {
        await startServer();
      });
      on("after:run", async () => {
        await stopServer();
      });
      process.on("exit", () => {
        stopServer();
      });
      return config;
    },
  },
});
