<script lang="ts">
    import { theme } from './store';

    let isDark = false;
    $: {
        if (typeof window !== 'undefined') {
            isDark = $theme === 'dark' || ($theme === 'system' && window.matchMedia('(prefers-color-scheme: dark)').matches);
        }
    }
</script>

<div class="absolute inset-0 w-full h-full overflow-hidden -z-10">
    <!-- Fundo Escuro (Cidade à Noite) -->
    <div class="absolute inset-0 w-full h-full transition-opacity duration-1000 {isDark ? 'opacity-100' : 'opacity-0'}">
        <svg viewBox="0 0 1920 1080" preserveAspectRatio="xMidYMid slice" class="w-full h-full">
            <defs>
                <linearGradient id="grad-dark-sky" x1="0%" y1="0%" x2="0%" y2="100%">
                    <stop offset="0%" style="stop-color:#0c142b" />
                    <stop offset="100%" style="stop-color:#004d2c" />
                </linearGradient>
            </defs>
            <rect width="1920" height="1080" fill="url(#grad-dark-sky)" />
            
        </svg>
    </div>

    <div class="absolute inset-0 w-full h-full transition-opacity duration-1000 {isDark ? 'opacity-0' : 'opacity-100'}">
        <svg viewBox="0 0 1920 1080" preserveAspectRatio="xMidYMid slice" class="w-full h-full">
            <defs>
                <linearGradient id="grad-light-sky" x1="0%" y1="0%" x2="0%" y2="100%">
                    <stop offset="0%" style="stop-color:#cceee3" />
                    <stop offset="100%" style="stop-color:#f0faf6" />
                </linearGradient>
            </defs>
            <rect width="1920" height="1080" fill="url(#grad-light-sky)" />
        </svg>
    </div>
</div>
