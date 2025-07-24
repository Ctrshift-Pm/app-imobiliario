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
                    <stop offset="100%" style="stop-color:#382c5d" />
                </linearGradient>
            </defs>
            <rect width="1920" height="1080" fill="url(#grad-dark-sky)" />
            <!-- Estrelas -->
            <circle cx="200" cy="300" r="2" fill="white" opacity="0.8" /><circle cx="500" cy="150" r="1.5" fill="white" opacity="0.6" /><circle cx="900" cy="400" r="2.5" fill="white" opacity="0.9" /><circle cx="1200" cy="250" r="1" fill="white" opacity="0.7" /><circle cx="1700" cy="350" r="2" fill="white" opacity="0.8" /><circle cx="700" cy="600" r="1.5" fill="white" opacity="0.5" /><circle cx="1500" cy="550" r="2" fill="white" opacity="0.9" />
            <!-- Lua -->
            <svg style="color: white" xmlns="http://www.w3.org/2000/svg" width="3000" height="170" x="200" y="220" fill="currentColor" class="bi bi-moon-fill" viewBox="0 0 16 16"> <path d="M6 .278a.768.768 0 0 1 .08.858 7.208 7.208 0 0 0-.878 3.46c0 4.021 3.278 7.277 7.318 7.277.527 0 1.04-.055 1.533-.16a.787.787 0 0 1 .81.316.733.733 0 0 1-.031.893A8.349 8.349 0 0 1 8.344 16C3.734 16 0 12.286 0 7.71 0 4.266 2.114 1.312 5.124.06A.752.752 0 0 1 6 .278z" fill="white" transform="scale(-1, 1)"></path> </svg>
            <!-- Skyline da Cidade -->
            <g fill="#1a202c" opacity="0.8">
                <rect x="0" y="700" width="150" height="380" />
                <rect x="160" y="650" width="200" height="430" />
                <rect x="370" y="750" width="180" height="330" />
                <rect x="560" y="600" width="250" height="480" />
                <rect x="820" y="720" width="150" height="360" />
                <rect x="980" y="550" width="300" height="530" />
                <rect x="1290" y="680" width="220" height="400" />
                <rect x="1520" y="780" width="180" height="300" />
                <rect x="1710" y="620" width="210" height="460" />
            </g>
             <!-- Janelas Iluminadas -->
            <g fill="#f0e68c" opacity="0.7">
                <rect x="180" y="670" width="15" height="20" /><rect x="220" y="720" width="15" height="20" /><rect x="300" y="800" width="15" height="20" />
                <rect x="210" y="670" width="15" height="20" /><rect x="240" y="670" width="15" height="20" /><rect x="270" y="670" width="15" height="20" />
                <rect x="300" y="670" width="15" height="20" /><rect x="330" y="720" width="15" height="20" />
                <rect x="600" y="650" width="15" height="20" /><rect x="650" y="700" width="15" height="20" /><rect x="750" y="820" width="15" height="20" />
                <rect x="1050" y="600" width="15" height="30" /><rect x="1150" y="750" width="15" height="20" /><rect x="1220" y="680" width="15" height="20" />
                <rect x="1750" y="680" width="15" height="20" /><rect x="1800" y="750" width="15" height="20" />
            </g>
        </svg>
    </div>

    <!-- Fundo Claro (Cidade de Dia) -->
    <div class="absolute inset-0 w-full h-full transition-opacity duration-1000 {isDark ? 'opacity-0' : 'opacity-100'}">
        <svg viewBox="0 0 1920 1080" preserveAspectRatio="xMidYMid slice" class="w-full h-full">
            <defs>
                <linearGradient id="grad-light-sky" x1="0%" y1="0%" x2="0%" y2="100%">
                    <stop offset="0%" style="stop-color:#87ceeb" />
                    <stop offset="100%" style="stop-color:#e0f2fe" />
                </linearGradient>
            </defs>
            <rect width="1920" height="1080" fill="url(#grad-light-sky)" />
            <!-- Sol -->
            <circle cx="200" cy="200" r="80" fill="#ffffe0" opacity="0.9" />
            <!-- Skyline da Cidade -->
            <g fill="#a0aec0" opacity="0.9">
                <rect x="0" y="700" width="150" height="380" />
                <rect x="160" y="650" width="200" height="430" />
                <rect x="370" y="750" width="180" height="330" />
                <rect x="560" y="600" width="250" height="480" />
                <rect x="820" y="720" width="150" height="360" />
                <rect x="980" y="550" width="300" height="530" />
                <rect x="1290" y="680" width="220" height="400" />
                <rect x="1520" y="780" width="180" height="300" />
                <rect x="1710" y="620" width="210" height="460" />
            </g>
        </svg>
    </div>
</div>
