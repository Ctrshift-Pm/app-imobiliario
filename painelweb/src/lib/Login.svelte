<script lang="ts">
  import { authToken } from './store';
  import Background from './Background.svelte';

  let email: string = 'admin@imobiliaria.com';
  let password: string = 'admin123';
  let error: string = '';
  let isLoading: boolean = false;

  const API_URL: string = 'http://localhost:3333';

  async function handleLogin() {
    isLoading = true;
    error = '';
    try {
      const response = await fetch(`${API_URL}/admin/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password }),
      });
      const data = await response.json();
      if (!response.ok) throw new Error(data.error || 'Erro ao fazer login.');
      authToken.set(data.token);
    } catch (err) {
      if (err instanceof Error) {
        error = err.message;
      } else {
        error = 'Ocorreu um erro desconhecido.';
      }
    } finally {
      isLoading = false;
    }
  }
</script>

<div class="relative flex min-h-screen items-center justify-center p-4 overflow-hidden">
    <Background />
    <div class="w-full max-w-md rounded-2xl bg-white/80 dark:bg-slate-800/80 backdrop-blur-sm shadow-2xl shadow-black/20 overflow-hidden z-10">
        <div class="p-8 md:p-10 space-y-6">
            <div class="flex justify-center">
                <svg class="w-16 h-16 text-indigo-600" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"></path></svg>
            </div>
            <div class="text-center">
                <h2 class="text-3xl font-bold text-gray-900 dark:text-white">Painel Administrativo</h2>
                <p class="mt-2 text-gray-600 dark:text-gray-400">Faça login para continuar</p>
            </div>
            <form on:submit|preventDefault={handleLogin} class="space-y-6">
                <div>
                    <label for="email" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Email</label>
                    <input type="email" id="email" bind:value={email} required class="w-full px-4 py-2 mt-1 text-gray-800 bg-white/50 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 dark:bg-gray-700/50 dark:border-gray-600 dark:text-white dark:focus:ring-indigo-500 transition-all">
                </div>
                <div>
                    <label for="password" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Senha</label>
                    <input type="password" id="password" bind:value={password} required class="w-full px-4 py-2 mt-1 text-gray-800 bg-white/50 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 dark:bg-gray-700/50 dark:border-gray-600 dark:text-white dark:focus:ring-indigo-500 transition-all">
                </div>
                {#if error}
                    <p class="text-sm text-center text-red-500 dark:text-red-400 font-medium">{error}</p>
                {/if}
            </form>
        </div>
        <div class="relative h-24">
            <div class="absolute bottom-0 left-0 w-full h-full overflow-hidden">
                <svg viewBox="0 0 500 150" preserveAspectRatio="none" class="w-full h-full">
                    <path d="M-5.58,53.48 C149.99,150.00 349.20,-49.98 503.66,53.48 L500.00,150.00 L0.00,150.00 Z" class="fill-current text-indigo-600/50 dark:text-indigo-800/50"></path>
                    <path d="M-2.22,83.98 C149.99,100.00 271.49,-49.98 503.66,83.98 L500.00,150.00 L0.00,150.00 Z" class="fill-current text-indigo-500/50 dark:text-indigo-700/50"></path>
                </svg>
            </div>
            <div class="absolute inset-0 flex items-center justify-center">
                 <button on:click={handleLogin} disabled={isLoading} class="px-10 py-3 font-semibold text-white bg-indigo-600 rounded-lg shadow-lg hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-gray-800 focus:ring-indigo-500 transition-transform transform hover:scale-105 disabled:opacity-50 disabled:scale-100">
                    {isLoading ? 'A entrar...' : 'Login'}
                </button>
            </div>
        </div>
    </div>
</div>