import express, { Request, Response } from "express";
import { hello, ok } from "@crive/shared";

const app = express();
const PORT = Number(process.env.PORT || 4000);
const HOST = process.env.HOST || "0.0.0.0";

app.get("/health", (_req: Request, res: Response) => {
  res.json({ status: "ok", ok });
});

app.get("/version", (_req: Request, res: Response) => {
  res.json({ version: process.env.npm_package_version || "0.0.0" });
});

app.get("/hello", (_req: Request, res: Response) => {
  res.json({ message: hello() });
});

app.listen(PORT, HOST, () => {
  console.log(`API listening at http://${HOST}:${PORT}`);
});
