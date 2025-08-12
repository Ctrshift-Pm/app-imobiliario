<script lang="ts">
    import Sidebar from './Sidebar.svelte';
    import Header from './Header.svelte';
    import Table from './Table.svelte';
    import Modal from './Modal.svelte';
    import Pagination from './Pagination.svelte';
    import FilterControls from './FilterControls.svelte';
    import KpiCard from './KpiCard.svelte';
    import { authToken } from './store';
    import { onMount } from 'svelte';
    import type { Property, Broker, User, View } from './types'; // Importa o tipo View

    type DataItem = Property | Broker | User;
    
    let activeView: View = 'dashboard';
    let allData: DataItem[] = [];
    let headers: string[] = [];
    let isLoading: boolean = true;
    let showModal = false;
    let itemToDelete: { id: number; type: string } | null = null;
    let isSidebarOpen = false;

    // Estado para os controlos da tabela
    let searchTerm = '';
    let searchColumn = 'all';
    let itemsPerPage = 10;
    let currentPage = 1;
    let totalItems = 0;
    
    interface Stats {
        totalProperties: number;
        totalBrokers: number;
        totalUsers: number;
    }
    let stats: Stats | null = null;

    const API_URL = 'http://localhost:3333';

    const viewConfig = {
        dashboard: { title: 'Dashboard' },
        properties: { 
            endpoint: '/properties', 
            title: 'Gerenciamento de Imóveis', 
            headers: ['ID', 'Título', 'Tipo', 'Status', 'Preço', 'Cidade', 'Corretor ID'],
            filterOptions: [
                { value: 'id', label: 'ID do Imóvel' },
                { value: 'title', label: 'Título' },
                { value: 'type', label: 'Tipo' },
                { value: 'city', label: 'Cidade' },
                { value: 'price_gt', label: 'Preço >' },
                { value: 'price_lt', label: 'Preço <' },
                { value: 'broker_id', label: 'ID do Corretor' },
            ]
        },
        brokers: { 
            endpoint: '/admin/brokers', 
            title: 'Gerenciamento de Corretores', 
            headers: ['ID', 'Nome', 'Email', 'CRECI', 'Criado em'],
            filterOptions: [
                { value: 'name', label: 'Nome' },
                { value: 'email', label: 'Email' },
                { value: 'creci', label: 'CRECI' },
            ]
        },
        users: { 
            endpoint: '/admin/users', 
            title: 'Gerenciamento de Usuários', 
            headers: ['ID', 'Nome', 'Email', 'Telefone', 'Criado em'],
            filterOptions: [
                { value: 'name', label: 'Nome' },
                { value: 'email', label: 'Email' },
                { value: 'phone', label: 'Telefone' },
                { value: 'created_at', label: 'Data de Criação' },
            ]
        }
    };

    let debounceTimer: number;
    async function fetchData() {
        isLoading = true;
        const token = localStorage.getItem('authToken');
        if (!token) {
            authToken.set(null);
            return;
        }
        
        if (activeView === 'dashboard') {
            try {
                const response = await fetch(`${API_URL}/admin/dashboard/stats`, {
                    headers: { 'Authorization': `Bearer ${token}` }
                });
                if (!response.ok) throw new Error('Falha ao buscar estatísticas');
                stats = await response.json();
            } catch (error) {
                console.error(error);
                authToken.set(null);
            } finally {
                isLoading = false;
            }
            return;
        }

        const config = viewConfig[activeView];
        const params = new URLSearchParams({
            page: String(currentPage),
            limit: String(itemsPerPage),
            search: searchTerm,
            searchColumn: searchColumn,
        });

        try {
            const response = await fetch(`${API_URL}${config.endpoint}?${params.toString()}`, {
                headers: { 'Authorization': `Bearer ${token}` }
            });
            if (!response.ok) throw new Error('Falha na autenticação');
            
            const { data, total } = await response.json();
            allData = data; // Armazena todos os dados da API
            totalItems = total;
            headers = config.headers;
        } catch (error) {
            console.error(`Erro ao buscar dados de ${activeView}:`, error);
            authToken.set(null);
        } finally {
            isLoading = false;
        }
    }

    function changeView(newView: View) {
        activeView = newView;
        isSidebarOpen = false;
        searchTerm = '';
        searchColumn = 'all';
        currentPage = 1;
        fetchData();
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
            if (paginatedData.length === 1 && currentPage > 1) {
                currentPage--;
            } else {
                fetchData();
            }
        } catch (error) {
            console.error(`Erro ao deletar item:`, error);
        } finally {
            showModal = false;
            itemToDelete = null;
        }
    }

    onMount(() => {
        fetchData();
    });

    let initialLoad = true;
    $: {
        currentPage, itemsPerPage, searchTerm, searchColumn;
        if (initialLoad) {
            initialLoad = false;
        } else {
            clearTimeout(debounceTimer);
            debounceTimer = setTimeout(() => {
                if (searchTerm || itemsPerPage || searchColumn) {
                    currentPage = 1;
                }
                fetchData();
            }, 300);
        }
    }
    
    $: paginatedData = allData; // A API já retorna os dados paginados
    $: totalPages = Math.ceil(totalItems / itemsPerPage);

</script>

<div class="relative flex h-screen bg-gray-100 dark:bg-gray-900">
    <Sidebar bind:isOpen={isSidebarOpen} {activeView} onNavigate={changeView} />

    <div class="flex-1 flex flex-col overflow-hidden lg:pl-64">
        <Header pageTitle={viewConfig[activeView].title} onToggleSidebar={() => isSidebarOpen = !isSidebarOpen} />
        
        <main class="flex-1 overflow-x-hidden overflow-y-auto p-4 md:p-6">
             {#if isLoading}
                <div class="flex justify-center items-center h-full"><p class="text-gray-500 dark:text-gray-400">A carregar...</p></div>
             {:else if activeView === 'dashboard'}
                {#if stats}
                    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                        <KpiCard title="Total de Imóveis" value={stats.totalProperties} color="blue" />
                        <KpiCard title="Total de Corretores" value={stats.totalBrokers} color="green" />
                        <KpiCard title="Total de Utilizadores" value={stats.totalUsers} color="yellow" />
                    </div>
                {/if}
             {:else}
                <FilterControls 
                    bind:itemsPerPage
                    bind:searchTerm
                    bind:searchColumn
                    filterOptions={viewConfig[activeView].filterOptions}
                />
                <Table 
                    {headers} 
                    data={paginatedData} 
                    view={activeView}
                    onDelete={openDeleteModal}
                />
                <Pagination 
                    bind:currentPage
                    {totalPages} 
                    {totalItems}
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