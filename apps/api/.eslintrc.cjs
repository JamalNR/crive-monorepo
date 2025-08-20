/** minimal & tidak tergantung Next */
module.exports = {
  root: true,
  extends: ['eslint:recommended', 'prettier'],
  env: { node: true, es2022: true },
  parserOptions: { ecmaVersion: 'latest', sourceType: 'module', project: './tsconfig.json' },
  plugins: ['unused-imports'],
  rules: { 'unused-imports/no-unused-imports': 'error' }
};
