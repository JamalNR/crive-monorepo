import next from "eslint-config-next";
import js from "@eslint/js";
import ts from "typescript-eslint";

export default [
  js.configs.recommended,
  ...ts.configs.recommended,
  ...next(),
  {
    ignores: ["node_modules", "dist", ".next"],
  },
];
