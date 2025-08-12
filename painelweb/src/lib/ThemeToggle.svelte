<script lang="ts">
    import { theme } from './store';
</script>

<div class="flex items-center justify-center bg-gray-700 dark:bg-gray-800 rounded-lg p-1">
    <button on:click={() => $theme = 'light'} class="w-1/2 px-3 py-1 text-sm rounded-md transition-colors {$theme === 'light' ? 'bg-brand-green text-white' : 'text-gray-400 hover:text-white'}">Claro</button>
    <button on:click={() => $theme = 'dark'} class="w-1/2 px-3 py-1 text-sm rounded-md transition-colors {$theme === 'dark' ? 'bg-brand-green text-white' : 'text-gray-400 hover:text-white'}">Escuro</button>
</div>
