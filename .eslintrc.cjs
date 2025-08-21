// .eslintrc.cjs (root)
module.exports = {
  root: true,
  ignorePatterns: ['**/dist/**', '**/build/**', '**/.next/**', '**/node_modules/**'],
  overrides: [
    {
      files: ['**/*.{ts,tsx,js,jsx,cjs,mjs}'],
      parser: '@typescript-eslint/parser',
      parserOptions: { ecmaVersion: 'latest', sourceType: 'module' }, // tidak butuh tsconfig
      plugins: ['@typescript-eslint'],
      extends: [],  // tanpa rules ketat, aman
      rules: {},
    },
  ],
};
