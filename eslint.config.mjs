import eslintPluginPrettier from 'eslint-plugin-prettier'
import prettierConfig from 'eslint-config-prettier'
import tseslint from 'typescript-eslint'

export default tseslint.config(
  {
    ignores: ['node_modules/**', 'dist/**', 'build/**', '.out/**', '.next/**'],
  },
  tseslint.configs.recommended,
  {
    plugins: { prettier: eslintPluginPrettier },
    rules: { 'prettier/prettier': 'error' },
  },
  prettierConfig,
)
