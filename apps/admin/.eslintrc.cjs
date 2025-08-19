module.exports = {
  extends: ['next/core-web-vitals','prettier'],
  parserOptions: { project: './tsconfig.json' },
  rules: {
    'unused-imports/no-unused-imports': 'error',
  },
  plugins: ['unused-imports'],
};
