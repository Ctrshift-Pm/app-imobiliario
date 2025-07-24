<script lang="ts">
    import { authToken, theme } from './store';
    import ThemeToggle from './ThemeToggle.svelte';

    type View = 'properties' | 'brokers' | 'users';

    export let isOpen = false;
    export let activeView: View;
    export let onNavigate: (view: View) => void = () => {};
</script>

<!-- Overlay para mobile -->
<div 
    class="fixed inset-0 z-20 bg-black bg-opacity-50 transition-opacity lg:hidden {isOpen ? 'opacity-100' : 'opacity-0 pointer-events-none'}" 
    on:click={() => isOpen = false}
    on:keydown|self={(e) => { if (e.key === 'Enter' || e.key === ' ') isOpen = false }}
    role="button"
    tabindex="0"
    aria-label="Fechar menu"
></div>

<!-- Sidebar -->
<aside class="fixed inset-y-0 left-0 z-30 w-64 bg-gray-800 dark:bg-gray-900 text-white flex flex-col transform transition-transform duration-300 ease-in-out lg:translate-x-0 {isOpen ? 'translate-x-0' : '-translate-x-full'}">
    <div class="h-16 flex items-center justify-center text-2xl font-bold border-b border-gray-700 dark:border-gray-800">Imobiliária</div>
    <nav class="flex-1 px-4 py-4 space-y-2">
        <button class="sidebar-link w-full text-left flex items-center px-4 py-2 rounded-lg hover:bg-gray-700 transition-colors" class:active={activeView === 'properties'} on:click={() => onNavigate('properties')}>
            <svg class="w-6 h-6 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"></path></svg>
            Imóveis
        </button>
        <button class="sidebar-link w-full text-left flex items-center px-4 py-2 rounded-lg hover:bg-gray-700 transition-colors" class:active={activeView === 'brokers'} on:click={() => onNavigate('brokers')}>
            <svg class="w-6 h-6 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283-.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"></path></svg>
            Corretores
        </button>
        <button class="sidebar-link w-full text-left flex items-center px-4 py-2 rounded-lg hover:bg-gray-700 transition-colors" class:active={activeView === 'users'} on:click={() => onNavigate('users')}>
            <svg class="w-6 h-6 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M15 21v-2a4 4 0 00-4-4H9a4 4 0 00-4 4v2"></path></svg>
            Usuários
        </button>
    </nav>
    <div class="px-4 py-4 border-t border-gray-700 dark:border-gray-800 space-y-4">
        <ThemeToggle />
        <button on:click={() => authToken.set(null)} class="w-full flex items-center justify-center px-4 py-2 rounded-lg text-red-400 hover:bg-red-500 hover:text-white transition-colors">
            <svg class="w-6 h-6 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path></svg>
            Sair
        </button>
    </div>
</aside>