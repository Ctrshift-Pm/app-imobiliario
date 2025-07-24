<script lang="ts">
    export let pageTitle: string;
    export let onToggleSidebar: () => void = () => {};
</script>

<header class="bg-white dark:bg-gray-800 shadow-sm">
    <div class="container mx-auto px-4 sm:px-6 lg:px-8 py-4 flex justify-between items-center">
        <button on:click={onToggleSidebar} class="text-gray-500 dark:text-gray-400 focus:outline-none lg:hidden" aria-label="Abrir menu">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path></svg>
        </button>
        
        <h1 class="text-xl md:text-2xl font-semibold text-gray-800 dark:text-white">{pageTitle}</h1>
        
        <div class="w-6 lg:hidden"></div>
    </div>
</header>