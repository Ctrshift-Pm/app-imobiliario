<script lang="ts">
    import { onMount } from 'svelte';

    export let onConfirm: () => void = () => {};
    export let onCancel: () => void = () => {};

    function handleKeydown(event: KeyboardEvent) {
        if (event.key === 'Escape') {
            onCancel();
        }
    }

    onMount(() => {
        const modal = document.querySelector('[role="dialog"]');
        if (modal instanceof HTMLElement) {
            modal.focus();
        }
    });
</script>

<svelte:window on:keydown={handleKeydown}/>

<div 
    class="fixed inset-0 bg-gray-800 bg-opacity-60 z-50 flex items-center justify-center" 
    on:click|self={onCancel}
    on:keydown|self={(e) => { if (e.key === 'Enter' || e.key === ' ') onCancel() }}
    role="dialog"
    aria-modal="true"
    tabindex="-1"
>
    <div class="bg-white dark:bg-gray-800 p-6 rounded-lg shadow-2xl m-4 max-w-sm w-full">
        <div class="text-center">
            <div class="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-red-100 dark:bg-red-900/50">
                <svg class="h-6 w-6 text-red-600 dark:text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path></svg>
            </div>
            
            <slot />

            <div class="mt-4 flex justify-center space-x-4">
                <button class="px-6 py-2 bg-gray-200 text-gray-800 font-medium rounded-md hover:bg-gray-300 dark:bg-gray-700 dark:text-gray-300 dark:hover:bg-gray-600" on:click={onCancel}>
                    Cancelar
                </button>
                <button class="px-6 py-2 bg-red-600 text-white font-medium rounded-md hover:bg-red-700" on:click={onConfirm}>
                    Excluir
                </button>
            </div>
        </div>
    </div>
</div>