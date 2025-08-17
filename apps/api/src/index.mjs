import express from "express";
import { ok } from "@crive/shared";

const app = express();
const PORT = Number(process.env.PORT || 4000);
const HOST = process.env.HOST || "0.0.0.0";

app.get("/health", (_req, res) => res.json({ status: "ok" }));
app.get("/version", (_req, res) =>
  res.json({ version: process.env.npm_package_version || "0.0.0" })
);
app.get("/hello", (_req, res) => res.json({ message: "hello", shared_ok: ok }));

const server = app.listen(PORT, HOST, () => {
  console.log(`[API] listening on http://${HOST}:${PORT}`);
});

process.on("SIGTERM", () => server.close());
process.on("SIGINT", () => server.close());
