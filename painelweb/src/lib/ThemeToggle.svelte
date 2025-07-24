<script lang="ts">
    import { theme } from './store';
</script>

<div class="flex items-center justify-center bg-gray-700 dark:bg-gray-800 rounded-lg p-1">
    <button on:click={() => $theme = 'light'} class="px-3 py-1 text-sm rounded-md transition-colors {$theme === 'light' ? 'bg-indigo-500 text-white' : 'text-gray-400 hover:text-white'}">Claro</button>
    <button on:click={() => $theme = 'dark'} class="px-3 py-1 text-sm rounded-md transition-colors {$theme === 'dark' ? 'bg-indigo-500 text-white' : 'text-gray-400 hover:text-white'}">Escuro</button>
    <button on:click={() => $theme = 'system'} class="px-3 py-1 text-sm rounded-md transition-colors {$theme === 'system' ? 'bg-indigo-500 text-white' : 'text-gray-400 hover:text-white'}">Sistema</button>
</div>
