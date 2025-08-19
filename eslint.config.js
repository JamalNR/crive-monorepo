// eslint.config.js (flat config untuk ESLint v9)
// Berlaku untuk: apps/api & packages/shared. Admin tetap pakai "next lint".
import tsParser from "@typescript-eslint/parser";
import tsPlugin from "@typescript-eslint/eslint-plugin";
import importPlugin from "eslint-plugin-import";
import unused from "eslint-plugin-unused-imports";

export default [
  // Abaikan output build & vendor
  {
    ignores: ["dist", "node_modules", ".next", "out", "coverage"],
  },

  // Aturan untuk API & Shared (TypeScript/Node)
  {
    files: ["apps/api/**/*.{ts,tsx,js}", "packages/shared/**/*.{ts,tsx,js}"],
    languageOptions: {
      parser: tsParser,
      parserOptions: {
        tsconfigRootDir: process.cwd(),
        project: [
          "./apps/api/tsconfig.json",
          "./packages/shared/tsconfig.json",
        ],
      },
    },
    plugins: {
      "@typescript-eslint": tsPlugin,
      import: importPlugin,
      "unused-imports": unused,
    },
    rules: {
      "unused-imports/no-unused-imports": "error",
      "import/order": [
        "error",
        {
          "newlines-between": "always",
          alphabetize: { order: "asc" },
        },
      ],
    },
  },
];
