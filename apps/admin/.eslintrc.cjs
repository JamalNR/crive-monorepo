/** minimal & kompatibel dgn ESLint v8 */
module.exports = {
  root: true,
  extends: ['next/core-web-vitals', 'prettier'],
  parserOptions: { project: './tsconfig.json' },
  plugins: ['unused-imports'],
  rules: {
    'unused-imports/no-unused-imports': 'error'
  }
};
