import { writable, type Writable } from 'svelte/store';

export const authToken: Writable<string | null> = writable(localStorage.getItem('authToken'));
authToken.subscribe(value => {
  if (value) {
    localStorage.setItem('authToken', value);
  } else {
    localStorage.removeItem('authToken');
  }
});

type Theme = 'light' | 'dark' | 'system';
const storedTheme = localStorage.getItem('theme') as Theme | null;
export const theme: Writable<Theme> = writable(storedTheme || 'system');
theme.subscribe(value => {
    localStorage.setItem('theme', value);
});