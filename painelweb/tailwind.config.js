export default {
  content: [
    "./index.html",
    "./src/**/*.{svelte,js,ts,jsx,tsx}",
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        'brand-green': '#00a859',
        'brand-green-dark': '#008245',
      }
    },
  },
  plugins: [],
}