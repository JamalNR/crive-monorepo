// @ts-check
import js from "@eslint/js";
import ts from "typescript-eslint";

export default [
  js.configs.recommended,
  ...ts.configs.recommended,
  {
    files: ["**/*.{ts,tsx,js,jsx}"],
    ignores: ["**/dist/**", "**/.next/**", "**/node_modules/**", "**/out/**"]
  }
];
