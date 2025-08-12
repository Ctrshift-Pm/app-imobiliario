<script lang="ts">
  import { authToken } from './store';
  import Background from './Background.svelte';
  import Logo from './Logo.svelte';

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
    <div class="w-full max-w-sm rounded-2xl bg-white/90 dark:bg-gray-800/90 backdrop-blur-md shadow-2xl shadow-black/20 z-10 overflow-hidden">
        <div class="p-8 md:p-10 space-y-6">
            <div class="flex justify-center">
                <Logo className="w-20 h-20" />
            </div>
            <div class="text-center">
                <h2 class="text-3xl font-bold text-gray-900 dark:text-white">ConectImóvel</h2>
                <p class="mt-1 text-gray-500 dark:text-gray-400">Painel Administrativo</p>
            </div>
            <form on:submit|preventDefault={handleLogin} class="space-y-6">
                <div>
                    <input type="email" id="email" bind:value={email} required placeholder="Email"
                           class="w-full px-4 py-3 text-gray-800 bg-gray-100 border-2 border-transparent rounded-lg focus:outline-none focus:ring-2 focus:ring-brand-green focus:border-transparent dark:bg-gray-700 dark:text-white transition-all">
                </div>
                <div>
                    <input type="password" id="password" bind:value={password} required placeholder="Senha"
                           class="w-full px-4 py-3 text-gray-800 bg-gray-100 border-2 border-transparent rounded-lg focus:outline-none focus:ring-2 focus:ring-brand-green focus:border-transparent dark:bg-gray-700 dark:text-white transition-all">
                </div>
                {#if error}
                    <p class="text-sm text-center text-red-500 dark:text-red-400 font-medium">{error}</p>
                {/if}
            </form>
        </div>
        <div class="relative h-24">
            <div class="absolute bottom-0 left-0 w-full h-full overflow-hidden">
                <svg viewBox="0 0 500 150" preserveAspectRatio="none" class="w-full h-full">
                    <path d="M-5.58,53.48 C149.99,150.00 349.20,-49.98 503.66,53.48 L500.00,150.00 L0.00,150.00 Z" class="fill-current text-brand-green-dark/50"></path>
                    <path d="M-2.22,83.98 C149.99,100.00 271.49,-49.98 503.66,83.98 L500.00,150.00 L0.00,150.00 Z" class="fill-current text-brand-green/50"></path>
                </svg>
            </div>
            <div class="absolute inset-0 flex items-center justify-center">
                 <button on:click={handleLogin} disabled={isLoading} class="px-10 py-3 font-semibold text-white bg-brand-green rounded-lg shadow-lg hover:bg-brand-green-dark focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-gray-800 focus:ring-brand-green transition-transform transform hover:scale-105 disabled:opacity-70 disabled:scale-100">
                    {isLoading ? 'A entrar...' : 'Login'}
                </button>
            </div>
        </div>
    </div>
</div>
