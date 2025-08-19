import express from "express";
import { hello } from "@crive/shared";

const app = express();
const port = process.env.PORT || 3001;

app.get("/", (_req, res) => {
  res.json({ ok: true, msg: hello("api") });
});

app.listen(port, () => {
  // eslint-disable-next-line no-console
  console.log(`API listening on :${port}`);
});
