/* root */
module.exports = {
  root: true,
  parser: '@typescript-eslint/parser',
  parserOptions: { tsconfigRootDir: __dirname },
  plugins: ['@typescript-eslint', 'import', 'unused-imports'],
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:import/recommended',
    'plugin:import/typescript',
    'prettier'
  ],
  rules: {
    'unused-imports/no-unused-imports': 'error',
    'import/order': ['error', { 'newlines-between': 'always', alphabetize: { order: 'asc' } }],
  },
  ignorePatterns: ['dist','node_modules','coverage'],
  overrides: [
    // API (Node)
    {
      files: ['apps/api/**/*.{ts,tsx}'],
      env: { node: true },
      parserOptions: { project: 'apps/api/tsconfig.json' },
    },
    // Shared (Node/Lib)
    {
      files: ['packages/shared/**/*.{ts,tsx}'],
      env: { node: true },
      parserOptions: { project: 'packages/shared/tsconfig.json' },
    },
  ],
};
