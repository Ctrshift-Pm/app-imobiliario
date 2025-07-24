<script lang="ts">
    import type { Property, Broker, User } from './types';

    export let headers: string[];
    export let data: (Partial<Property> | Partial<Broker> | Partial<User>)[];
    export let type: string;
    export let onDelete: (detail: { id: number; type: string }) => void = () => {};

    function handleDelete(id: number) {
        onDelete({ id, type });
    }
</script>

<div class="overflow-x-auto bg-white dark:bg-gray-800 rounded-lg shadow-md">
    <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
        <thead class="bg-gray-50 dark:bg-gray-700">
            <tr>
                {#each headers as header}
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider whitespace-nowrap">{header}</th>
                {/each}
                <th scope="col" class="relative px-6 py-3"><span class="sr-only">Ações</span></th>
            </tr>
        </thead>
        <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
            {#if data.length === 0}
                <tr><td colspan={headers.length + 1} class="px-6 py-4 text-center text-gray-500 dark:text-gray-400">Nenhum item encontrado.</td></tr>
            {:else}
                {#each data as item (item.id)}
                    <tr class="hover:bg-gray-50 dark:hover:bg-gray-700">
                        {#each Object.values(item) as value}
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-700 dark:text-gray-300">{value}</td>
                        {/each}
                        <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                            <button class="font-semibold text-red-600 hover:text-red-800 dark:text-red-500 dark:hover:text-red-400" on:click={() => { if (item.id) handleDelete(item.id) }}>Excluir</button>
                        </td>
                    </tr>
                {/each}
            {/if}
        </tbody>
    </table>
</div>