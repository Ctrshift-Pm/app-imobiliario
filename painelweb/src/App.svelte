<script lang="ts">
  import Login from './lib/Login.svelte';
  import Dashboard from './lib/Dashboard.svelte';
  import { authToken, theme } from './lib/store';
  import { onMount } from 'svelte';

  $: {
    if (typeof window !== 'undefined') {
      const isDark = 
        $theme === 'dark' || 
        ($theme === 'system' && window.matchMedia('(prefers-color-scheme: dark)').matches);
      document.documentElement.classList.toggle('dark', isDark);
    }
  }
</script>

<main class="h-full">
  {#if $authToken}
    <Dashboard />
  {:else}
    <Login />
  {/if}
</main>