<script lang="ts">
    export let currentPage: number;
    export let totalPages: number;
    export let totalItems: number;
    export let itemsPerPage: number;

    $: startItem = totalItems > 0 ? (currentPage - 1) * itemsPerPage + 1 : 0;
    $: endItem = Math.min(currentPage * itemsPerPage, totalItems);
</script>

<div class="mt-4 flex flex-col md:flex-row items-center justify-between text-sm text-gray-700 dark:text-gray-300">
    <p class="mb-2 md:mb-0">
        A mostrar <strong>{startItem}</strong> a <strong>{endItem}</strong> de <strong>{totalItems}</strong> entradas
    </p>
    {#if totalPages > 1}
    <div class="flex items-center space-x-1">
        <button 
            class="px-3 py-1 rounded-md bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 disabled:opacity-50 transition-colors"
            disabled={currentPage === 1}
            on:click={() => currentPage--}
        >
            Anterior
        </button>
        
        <span class="px-3 py-1">
            Página {currentPage} de {totalPages}
        </span>

        <button 
            class="px-3 py-1 rounded-md bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 disabled:opacity-50 transition-colors"
            disabled={currentPage === totalPages}
            on:click={() => currentPage++}
        >
            Próximo
        </button>
    </div>
    {/if}
</div>