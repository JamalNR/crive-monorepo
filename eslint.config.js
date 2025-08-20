import js from '@eslint/js';
import tseslint from 'typescript-eslint';
import globals from 'globals';

export default [
  js.configs.recommended,
  ...tseslint.configs.recommended,
  {
    languageOptions: {
      globals: { ...globals.node }
    },
    ignores: ['**/node_modules/**','**/dist/**','**/build/**','**/.next/**','**/out/**'],
    rules: {
      '@typescript-eslint/no-explicit-any': 'off'
    }
  }
];
