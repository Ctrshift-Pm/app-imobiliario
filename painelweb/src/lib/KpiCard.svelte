<script lang="ts">
    export let title: string;
    export let value: number;
    export let color: 'blue' | 'green' | 'yellow' = 'blue';

    const colorClasses = {
        blue: 'bg-blue-500',
        green: 'bg-green-500',
        yellow: 'bg-yellow-500',
    };
</script>

<div class="bg-white dark:bg-gray-800 p-6 rounded-lg shadow-md flex items-center justify-between">
    <div>
        <p class="text-sm font-medium text-gray-500 dark:text-gray-400 uppercase">{title}</p>
        <p class="text-3xl font-bold text-gray-900 dark:text-white">{value}</p>
    </div>
    <div class="p-3 rounded-full {colorClasses[color]} text-white">
        <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            {#if title.includes('Imóveis')}
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m-1 4h1m5-4h1m-1 4h1m-1-8h1m-5 8h1m-1-4h1"></path>
            {:else if title.includes('Corretores')}
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283-.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"></path>
            {:else}
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M15 21v-2a4 4 0 00-4-4H9a4 4 0 00-4 4v2"></path>
            {/if}
        </svg>
    </div>
</div>