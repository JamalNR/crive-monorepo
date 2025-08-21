/** Minimal ESLint config for API (TypeScript) */
module.exports = {
  parser: '@typescript-eslint/parser',
  parserOptions: {
    project: ['./tsconfig.json'],
    tsconfigRootDir: __dirname,
  },
  plugins: ['@typescript-eslint'],
  extends: [],                 // no strict rules → tidak memicu error gaya
  ignorePatterns: ['dist', 'build', 'node_modules'],
  rules: {},                   // tambahkan rules nanti sesuai kebutuhan
};
