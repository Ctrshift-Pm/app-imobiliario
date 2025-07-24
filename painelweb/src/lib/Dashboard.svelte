<script lang="ts">
    import Sidebar from './Sidebar.svelte';
    import Header from './Header.svelte';
    import Table from './Table.svelte';
    import Modal from './Modal.svelte';
    import Pagination from './Pagination.svelte';
    import { authToken } from './store';
    import { onMount } from 'svelte';
    import type { Property, Broker, User } from './types';

    type View = 'properties' | 'brokers' | 'users';
    type DataItem = Property | Broker | User;
    
    let activeView: View = 'properties';
    let allData: DataItem[] = [];
    let headers: string[] = [];
    let isLoading: boolean = true;
    let showModal = false;
    let itemToDelete: { id: number; type: string } | null = null;
    let isSidebarOpen = false;

    // Estado para os controlos da tabela
    let searchTerm = '';
    let itemsPerPage = 10;
    let currentPage = 1;

    const API_URL = 'http://localhost:3333';

    const viewConfig = {
        properties: { endpoint: '/properties', title: 'Gerenciamento de Imóveis', headers: ['ID', 'Título', 'Tipo', 'Status', 'Preço', 'Cidade', 'Quartos', 'Corretor ID', 'Criado em'] },
        brokers: { endpoint: '/admin/brokers', title: 'Gerenciamento de Corretores', headers: ['ID', 'Nome', 'Email', 'CRECI', 'Criado em'] },
        users: { endpoint: '/admin/users', title: 'Gerenciamento de Usuários', headers: ['ID', 'Nome', 'Email', 'Telefone', 'Criado em'] }
    };

    async function fetchData(view: View) {
        isLoading = true;
        const token = localStorage.getItem('authToken');
        if (!token) {
            authToken.set(null);
            return;
        }
        const config = viewConfig[view];
        try {
            const response = await fetch(`${API_URL}${config.endpoint}`, {
                headers: { 'Authorization': `Bearer ${token}` }
            });
            if (!response.ok) throw new Error('Falha na autenticação');
            
            allData = await response.json();
            headers = config.headers;
        } catch (error) {
            console.error(`Erro ao buscar dados de ${view}:`, error);
            authToken.set(null);
        } finally {
            isLoading = false;
        }
    }

    function changeView(newView: View) {
        activeView = newView;
        isSidebarOpen = false;
        searchTerm = '';
        currentPage = 1;
        fetchData(newView);
    }

    function openDeleteModal(detail: { id: number; type: string }) {
        itemToDelete = detail;
        showModal = true;
    }

    async function handleDeleteConfirm() {
        if (!itemToDelete) return;
        const token = localStorage.getItem('authToken');
        const { id, type } = itemToDelete;
        const endpoint = type === 'property' ? `/admin/properties/${id}` : `/admin/${type}s/${id}`;
        try {
            await fetch(`${API_URL}${endpoint}`, {
                method: 'DELETE',
                headers: { 'Authorization': `Bearer ${token}` }
            });
            fetchData(activeView);
        } catch (error) {
            console.error(`Erro ao deletar item:`, error);
        } finally {
            showModal = false;
            itemToDelete = null;
        }
    }

    onMount(() => {
        fetchData('properties');
    });

    // Lógica reativa para filtrar e paginar os dados
    $: filteredData = allData.filter(item => {
        if (!searchTerm) return true;
        const term = searchTerm.toLowerCase();
        // Pesquisa em todas as propriedades do objeto
        return Object.values(item).some(value => 
            String(value).toLowerCase().includes(term)
        );
    });

    $: paginatedData = filteredData.slice((currentPage - 1) * itemsPerPage, currentPage * itemsPerPage);
    $: totalPages = Math.ceil(filteredData.length / itemsPerPage);

</script>

<div class="relative flex h-screen bg-gray-100 dark:bg-gray-900">
    <Sidebar bind:isOpen={isSidebarOpen} {activeView} onNavigate={changeView} />

    <div class="flex-1 flex flex-col overflow-hidden lg:pl-64">
        <Header pageTitle={viewConfig[activeView].title} onToggleSidebar={() => isSidebarOpen = !isSidebarOpen} />
        
        <main class="flex-1 overflow-x-hidden overflow-y-auto p-4 md:p-6">
            {#if isLoading}
                <div class="flex justify-center items-center h-full"><p class="text-gray-500 dark:text-gray-400">A carregar dados...</p></div>
            {:else}
                <!-- Controlos da Tabela -->
                <div class="mb-4 flex flex-col md:flex-row items-center justify-between gap-4">
                    <div class="flex items-center gap-2">
                        <label for="items-per-page" class="text-sm font-medium text-gray-700 dark:text-gray-300">Mostrar</label>
                        <select id="items-per-page" bind:value={itemsPerPage} class="bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm text-sm p-2 focus:outline-none focus:ring-2 focus:ring-indigo-500">
                            <option value={10}>10</option>
                            <option value={20}>20</option>
                            <option value={50}>50</option>
                            <option value={100}>100</option>
                        </select>
                        <span class="text-sm text-gray-700 dark:text-gray-300">entradas</span>
                    </div>
                    <div class="relative w-full md:w-auto">
                        <input type="text" bind:value={searchTerm} placeholder="Pesquisar em tudo..." class="w-full md:w-80 pl-10 pr-4 py-2 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-indigo-500">
                        <span class="absolute inset-y-0 left-0 flex items-center pl-3">
                            <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path></svg>
                        </span>
                    </div>
                </div>

                <Table {headers} data={paginatedData} type={activeView.slice(0, -1)} onDelete={openDeleteModal} />

                <Pagination 
                    bind:currentPage={currentPage} 
                    {totalPages} 
                    totalItems={filteredData.length}
                    {itemsPerPage}
                />
            {/if}
        </main>
    </div>
</div>

{#if showModal}
    <Modal onConfirm={handleDeleteConfirm} onCancel={() => showModal = false}>
        <h3 class="text-lg font-semibold text-gray-900 dark:text-white mt-5">Confirmar Exclusão</h3>
        <p class="text-sm text-gray-600 dark:text-gray-400 mt-2 px-4 py-3">
            Você tem certeza que deseja excluir o {itemToDelete?.type} de ID {itemToDelete?.id}?
        </p>
    </Modal>
{/if}