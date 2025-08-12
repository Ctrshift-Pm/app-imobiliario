<script lang="ts">
    import { onMount } from 'svelte';
    import { authToken } from './store';
    import KpiCard from './KpiCard.svelte';

    interface Stats {
        totalProperties: number;
        totalBrokers: number;
        totalUsers: number;
    }

    let stats: Stats | null = null;
    let isLoading = true;
    const API_URL = 'http://localhost:3333';

    onMount(async () => {
        const token = localStorage.getItem('authToken');
        if (!token) {
            authToken.set(null);
            return;
        }
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
    });
</script>

<div>
    {#if isLoading}
        <p class="text-center text-gray-500 dark:text-gray-400">A carregar estatísticas...</p>
    {:else if stats}
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <KpiCard title="Total de Imóveis" value={stats.totalProperties} color="blue" />
            <KpiCard title="Total de Corretores" value={stats.totalBrokers} color="green" />
            <KpiCard title="Total de Utilizadores" value={stats.totalUsers} color="yellow" />
        </div>
        <!-- Futuramente, os gráficos podem ser adicionados aqui -->
    {/if}
</div>