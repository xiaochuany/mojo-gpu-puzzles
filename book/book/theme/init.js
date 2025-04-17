// Initialize Mojo syntax highlighting
document.addEventListener('DOMContentLoaded', (event) => {
    // If hljs is loaded, add 'mojo' as a recognized language alias for highlighting
    if (window.hljs) {
        // Register aliases for Mojo
        hljs.registerAliases(['mojo', '🔥'], { languageName: 'mojo' });

        // Force highlighting of all code blocks
        document.querySelectorAll('pre code').forEach((block) => {
            if (block.className.includes('language-mojo') || block.className.includes('language-🔥')) {
                hljs.highlightElement(block);
            }
        });
    }
});
