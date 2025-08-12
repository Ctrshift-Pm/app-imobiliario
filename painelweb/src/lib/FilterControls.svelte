<script lang="ts">
    export let itemsPerPage: number;
    export let searchTerm: string;
    export let searchColumn: string;
    export let filterOptions: { value: string; label: string }[];
</script>

<div class="mb-4 flex flex-col md:flex-row items-center justify-between gap-4">
    <div class="flex items-center gap-2">
        <label for="items-per-page" class="text-sm font-medium text-gray-700 dark:text-gray-300 whitespace-nowrap">Mostrar</label>
        <select id="items-per-page" bind:value={itemsPerPage} class="bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-700 dark:text-zinc-50 rounded-md shadow-sm text-sm p-2 focus:outline-none focus:ring-2 focus:ring-brand-green">
            <option value={10}>10</option>
            <option value={20}>20</option>
            <option value={50}>50</option>
            <option value={100}>100</option>
        </select>
        <span class="text-sm text-gray-700 dark:text-gray-300">entradas</span>
    </div>

    <!-- Container da Pesquisa -->
    <div class="flex w-full md:w-auto rounded-lg shadow-sm">
        <!-- Dropdown de Filtro -->
        <select bind:value={searchColumn} class="px-4 py-2 border border-r-0 border-gray-300 bg-gray-50 text-sm font-medium text-gray-700 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-brand-green rounded-l-lg dark:bg-gray-700 dark:border-gray-600 dark:text-gray-300 dark:hover:bg-gray-600">
            <option value="all">Tudo</option>
            {#each filterOptions as option}
                <option value={option.value}>{option.label}</option>
            {/each}
        </select>
        
        <!-- Barra de Pesquisa -->
        <div class="relative flex-grow">
            <input type="text" bind:value={searchTerm} placeholder="Pesquisar..." class="w-full md:w-72 pl-4 pr-10 py-2 bg-white border border-gray-300 rounded-r-lg focus:outline-none focus:ring-2 focus:ring-brand-green dark:bg-gray-800 dark:border-gray-600 dark:text-white">
            <span class="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none">
                <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path></svg>
            </span>
        </div>
    </div>
</div>
