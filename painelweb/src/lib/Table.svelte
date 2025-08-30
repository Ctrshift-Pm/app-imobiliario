<script lang="ts">
    import type { Property, Broker, User, View, DataItem } from './types';
    import { createEventDispatcher } from 'svelte';

    export let headers: string[];
    export let data: DataItem[];
    export let view: 'properties' | 'brokers' | 'users';
    export let editingId: number | null = null;
    export let editableItemData: Partial<DataItem> = {};
    export let isSaving = false;

    const dispatch = createEventDispatcher();

    // Estados locais para a lógica de venda
    let commissionDisplayValue = '';
    let isEditingSaleDetails = false;
    let showSaleDeletionWarning = false;

    function getSingularType(plural: 'properties' | 'brokers' | 'users'): 'property' | 'broker' | 'user' {
        if (plural === 'properties') {
            return 'property';
        }
        return plural.slice(0, -1) as 'broker' | 'user';
    }

    function handleEditStart(item: DataItem) {
        if (item.id === undefined) return;
        
        dispatch('editStart', item);
        
        if (view === 'properties') {
            const prop = item as Property;
            if (prop.status === 'Vendido') {
                isEditingSaleDetails = prop.sale_value == null; // Começa a editar se for uma nova venda
                updateCommissionDisplay(prop.sale_value, prop.commission_rate);
            }
        }
    }
    
    function handleSave() {
        if (editingId !== null) {
            dispatch('save', { id: editingId, data: editableItemData, type: getSingularType(view) });
        }
    }

    function handleCancel() {
        dispatch('editCancel');
    }

    function handleDelete(id: number | undefined) {
        if (id === undefined) return;
        dispatch('delete', { id, type: getSingularType(view) });
    }

    // Cores mais fortes para as bolinhas de status
    function getStatusDotClasses(status: string | undefined) {
        switch (status) {
            case 'Disponível': return 'bg-green-500';
            case 'Negociando': return 'bg-orange-500';
            case 'Vendido': return 'bg-red-500';
            case 'Alugado': return 'bg-blue-500';
            default: return 'bg-gray-400';
        }
    }

    // Cores para o fundo do texto (badge)
    function getStatusBadgeClasses(status: string | undefined) {
        switch (status) {
            case 'Disponível': return 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300';
            case 'Negociando': return 'bg-orange-100 text-orange-800 dark:bg-orange-900 dark:text-orange-300';
            case 'Vendido': return 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300';
            case 'Alugado': return 'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-300';
            default: return 'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300';
        }
    }
	
    function updateCommissionDisplay(saleValue?: number | null, commissionRate?: number | null) {
        const sv = Number(saleValue) || 0;
        const cr = Number(commissionRate) || 0;

        if (sv > 0 && cr > 0) {
            const commission = sv * (cr / 100);
            commissionDisplayValue = commission.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
        } else {
            commissionDisplayValue = '';
        }
    }

    // Bloco reativo para reiniciar o estado da venda quando a edição termina
    $: if (editingId === null) {
        commissionDisplayValue = '';
        isEditingSaleDetails = false;
        showSaleDeletionWarning = false;
    }

    $: if (view === 'properties' && editingId !== null) {
        const prop = editableItemData as Partial<Property>;
        const originalItem = data.find(d => d.id === editingId) as Property | undefined;
        showSaleDeletionWarning = originalItem?.status === 'Vendido' && prop.status !== 'Vendido';
    }
</script>

<div class="overflow-x-auto">
    <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
        <thead class="bg-gray-50 dark:bg-gray-700">
            <tr>
                {#each headers as header}
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider whitespace-nowrap">{header}</th>
                {/each}
                <th scope="col" class="relative px-6 py-3"><span class="sr-only">Ações</span></th>
            </tr>
        </thead>
        <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700 text-gray-600 dark:text-gray-300">
            {#if data.length === 0}
                <tr><td colspan={headers.length + 1} class="px-6 py-10 text-center text-gray-500 dark:text-gray-400">Nenhum resultado encontrado.</td></tr>
            {:else}
                {#each data as item (item.id)}
                    {@const isEditing = editingId === item.id && editableItemData.id === item.id}
                    <tr class="{isEditing ? 'bg-gray-50 dark:bg-gray-900' : 'hover:bg-gray-50 dark:hover:bg-gray-700'} transition-colors duration-150">
                        <!-- Células da Tabela -->
                        {#if isEditing}
                            {#if view === 'properties'}
                                {@const prop = editableItemData as Partial<Property>}
                                <td class="px-6 py-4 whitespace-nowrap"><span class="font-mono text-gray-500 dark:text-gray-400">{prop.id}</span></td>
                                <td class="px-2 py-2 whitespace-nowrap"><input type="text" value={prop.code || ''} class="w-24 p-2 border rounded-md bg-gray-100 dark:bg-gray-700 text-sm font-mono" disabled></td>
                                <td class="px-2 py-2"><input type="text" bind:value={prop.title} class="w-full p-2 border rounded-md bg-white dark:bg-gray-700 text-sm focus:ring-green-500 focus:border-green-500 text-gray-900 dark:text-white"></td>
                                <td class="px-2 py-2"><input type="text" bind:value={prop.type} class="w-full p-2 border rounded-md bg-white dark:bg-gray-700 text-sm focus:ring-green-500 focus:border-green-500 text-gray-900 dark:text-white"></td>
                                <td class="px-2 py-2">
                                    <select bind:value={prop.status} class="w-full p-2 border rounded-md bg-white dark:bg-gray-700 text-sm focus:ring-green-500 focus:border-green-500 text-gray-900 dark:text-white">
                                        <option value="Disponível">Disponível</option>
                                        <option value="Negociando">Negociando</option>
                                        <option value="Vendido">Vendido</option>
                                        <option value="Alugado">Alugado</option>
                                    </select>
                                </td>
                                <td class="px-2 py-2"><input type="number" step="1" bind:value={prop.price} class="w-full p-2 border rounded-md bg-white dark:bg-gray-700 text-sm focus:ring-green-500 focus:border-green-500 text-gray-900 dark:text-white"></td>
                                <td class="px-2 py-2"><input type="text" bind:value={prop.city} class="w-full p-2 border rounded-md bg-white dark:bg-gray-700 text-sm focus:ring-green-500 focus:border-green-500 text-gray-900 dark:text-white"></td>
                                <td class="px-2 py-2"><input type="text" value={prop.broker_name || ''} class="w-full p-2 border rounded-md bg-gray-100 dark:bg-gray-700 text-sm" disabled></td>
                            {:else}
                                <!-- Lógica de edição para corretores e utilizadores (se necessário) -->
                            {/if}
                        {:else}
                            <!-- MODO DE VISUALIZAÇÃO -->
                             {#if view === 'properties'}
                                {@const prop = item as Property}
                                <td class="px-6 py-4 whitespace-nowrap text-sm"><div class="flex items-center"><span class="h-2.5 w-2.5 rounded-full {getStatusDotClasses(prop.status)} mr-2.5"></span>{prop.id}</div></td>
                                <td class="px-6 py-4 whitespace-nowrap font-mono text-gray-500 dark:text-gray-400">{prop.code || 'N/A'}</td>
                                <td class="px-6 py-4 whitespace-nowrap text-gray-800 dark:text-gray-200 font-medium">{prop.title}</td>
                                <td class="px-6 py-4 whitespace-nowrap">{prop.type}</td>
                                <td class="px-6 py-4 whitespace-nowrap"><span class="px-2.5 py-0.5 rounded-full text-xs font-semibold {getStatusBadgeClasses(prop.status)}">{prop.status}</span></td>
                                <td class="px-6 py-4 whitespace-nowrap">{prop.price?.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' })}</td>
                                <td class="px-6 py-4 whitespace-nowrap">{prop.city}</td>
                                <td class="px-6 py-4 whitespace-nowrap">{prop.broker_name || 'N/A'}</td>
                            {:else if view === 'brokers'}
                                {@const broker = item as Broker}
                                <td class="px-6 py-4 whitespace-nowrap text-sm">{broker.id}</td>
                                <td class="px-6 py-4 whitespace-nowrap text-gray-800 dark:text-gray-200 font-medium">{broker.name}</td>
                                <td class="px-6 py-4 whitespace-nowrap">{broker.email}</td>
                                <td class="px-6 py-4 whitespace-nowrap">{broker.creci}</td>
                                <td class="px-6 py-4 whitespace-nowrap">{broker.created_at ? new Date(broker.created_at).toLocaleDateString('pt-BR') : ''}</td>
                                <td class="px-6 py-4 whitespace-nowrap">{broker.property_count}</td>
                            {:else if view === 'users'}
                                {@const user = item as User}
                                <td class="px-6 py-4 whitespace-nowrap text-sm">{user.id}</td>
                                <td class="px-6 py-4 whitespace-nowrap text-gray-800 dark:text-gray-200 font-medium">{user.name}</td>
                                <td class="px-6 py-4 whitespace-nowrap">{user.email}</td>
                                <td class="px-6 py-4 whitespace-nowrap">{user.phone}</td>
                                <td class="px-6 py-4 whitespace-nowrap">{user.created_at ? new Date(user.created_at).toLocaleDateString('pt-BR') : ''}</td>
                            {/if}
                        {/if}

                        <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                            {#if isEditing}
                                <button on:click={handleSave} disabled={isSaving} class="font-semibold transition-colors duration-200 text-green-600 hover:text-green-800 disabled:opacity-50 disabled:cursor-not-allowed">{isSaving ? 'Salvando...' : 'Salvar'}</button>
                                <button on:click={handleCancel} class="font-semibold transition-colors duration-200 text-gray-600 hover:text-gray-800 ml-4">Cancelar</button>
                            {:else}
                                <button on:click={() => handleEditStart(item)} class="inline-flex items-center gap-2 font-semibold transition-colors duration-200 text-green-600 hover:text-green-800">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="M15.502 1.94a.5.5 0 0 1 0 .706L14.459 3.69l-2-2L13.502.646a.5.5 0 0 1 .707 0l1.293 1.293zm-1.75 2.456-2-2L4.939 9.21a.5.5 0 0 0-.121.196l-.805 2.414a.25.25 0 0 0 .316.316l2.414-.805a.5.5 0 0 0 .196-.12l6.813-6.814z"/><path fill-rule="evenodd" d="M1 13.5A1.5 1.5 0 0 0 2.5 15h11a1.5 1.5 0 0 0 1.5-1.5v-6a.5.5 0 0 0-1 0v6a.5.5 0 0 1-.5.5h-11a.5.5 0 0 1-.5-.5v-11a.5.5 0 0 1 .5-.5H9a.5.5 0 0 0 0-1H2.5A1.5 1.5 0 0 0 1 2.5v11z"/></svg>
                                    Editar
                                </button>
                                <button on:click={() => handleDelete(item.id)} class="inline-flex items-center gap-2 font-semibold transition-colors duration-200 text-red-600 hover:text-red-800 ml-4">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="M5.5 5.5A.5.5 0 0 1 6 6v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5Zm2.5 0a.5.5 0 0 1 .5.5v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5Zm3 .5a.5.5 0 0 0-1 0v6a.5.5 0 0 0 1 0V6Z"/><path d="M14.5 3a1 1 0 0 1-1 1H13v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V4h-.5a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1H6a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1h3.5a1 1 0 0 1 1 1v1ZM4.118 4 4 4.059V13a1 1 0 0 0 1 1h6a1 1 0 0 0 1-1V4.059L11.882 4H4.118ZM2.5 3h11V2h-11v1Z"/></svg>
                                    Excluir
                                </button>
                            {/if}
                        </td>
                    </tr>
                    
                    {#if isEditing && view === 'properties'}
                        {@const prop = editableItemData as Partial<Property>}
                        {#if prop.status === 'Vendido'}
                            <tr class="bg-gray-50 dark:bg-gray-900">
                                <td colspan={headers.length + 1} class="p-4">
                                    <div class="p-4 rounded-md border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800">
                                        <div class="flex justify-between items-center mb-3">
                                            <h4 class="font-semibold text-sm text-gray-800 dark:text-gray-200">Detalhes da Venda</h4>
                                            {#if !isEditingSaleDetails && prop.sale_value != null}
                                                <button on:click={() => isEditingSaleDetails = true} class="text-sm font-semibold text-green-600 hover:text-green-800">Alterar Venda</button>
                                            {/if}
                                        </div>

                                        {#if isEditingSaleDetails}
                                            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                                                <div>
                                                    <label for="sale_value_{item.id}" class="block text-xs font-medium text-gray-500 mb-1">Valor da Venda (R$)</label>
                                                    <input id="sale_value_{item.id}" type="number" step="1" bind:value={prop.sale_value} placeholder="550000" class="w-full p-2 border rounded-md text-sm bg-white dark:bg-gray-700 text-gray-900 dark:text-white" on:input={() => updateCommissionDisplay(prop.sale_value, prop.commission_rate)}>
                                                </div>
                                                <div>
                                                    <label for="commission_rate_{item.id}" class="block text-xs font-medium text-gray-500 mb-1">Comissão (%)</label>
                                                    <input id="commission_rate_{item.id}" type="number" step="1" bind:value={prop.commission_rate} placeholder="5" class="w-full p-2 border rounded-md text-sm bg-white dark:bg-gray-700 text-gray-900 dark:text-white" on:input={() => updateCommissionDisplay(prop.sale_value, prop.commission_rate)}>
                                                </div>
                                                <div>
                                                    <p class="block text-xs font-medium text-gray-500 mb-1">Valor Final da Comissão</p>
                                                    <div class="h-10 flex items-center px-3 bg-gray-100 dark:bg-gray-700 rounded-md text-sm">{commissionDisplayValue || '...'}</div>
                                                </div>
                                            </div>
                                        {:else}
                                            <div class="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
                                                 <div>
                                                    <p class="block text-xs font-medium text-gray-500 dark:text-gray-400 mb-1">Valor da Venda (R$)</p>
                                                    <p class="font-semibold text-gray-800 dark:text-gray-200">{prop.sale_value?.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' }) || 'N/A'}</p>
                                                </div>
                                                <div>
                                                    <p class="block text-xs font-medium text-gray-500 dark:text-gray-400 mb-1">Comissão (%)</p>
                                                    <p class="font-semibold text-gray-800 dark:text-gray-200">{prop.commission_rate != null ? `${prop.commission_rate}%` : 'N/A'}</p>
                                                </div>
                                                <div>
                                                    <p class="block text-xs font-medium text-gray-500 dark:text-gray-400 mb-1">Valor Final da Comissão</p>
                                                    <p class="font-semibold text-gray-800 dark:text-gray-200">{commissionDisplayValue || 'N/A'}</p>
                                                </div>
                                            </div>
                                        {/if}
                                    </div>
                                </td>
                            </tr>
                        {/if}
                        
                        {#if showSaleDeletionWarning}
                            <tr class="warning-row">
                                <td colspan={headers.length + 1} class="px-6 py-2 text-center">
                                     <p class="text-xs font-semibold text-orange-600 dark:text-orange-400">
                                        Atenção: Ao salvar com um novo status, os detalhes da venda anterior serão permanentemente removidos.
                                    </p>
                                </td>
                            </tr>
                        {/if}
                    {/if}
                {/each}
            {/if}
        </tbody>
    </table>
</div>

<style>
    .warning-row {
        background-color: rgb(255 247 237); /* orange-50 */
    }
    :global(.dark) .warning-row {
        background-color: rgba(124, 45, 18, 0.2); /* Equivalente a orange-900 com 20% de opacidade */
    }
</style>

