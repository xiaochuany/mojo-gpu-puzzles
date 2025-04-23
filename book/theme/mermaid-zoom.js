let currentZoom = 1;

function zoomMermaid(factor) {
    const container = document.querySelector('.mermaid');
    if (!container) return;

    currentZoom *= factor;
    container.style.transform = `scale(${currentZoom})`;
    container.style.transformOrigin = 'top left';
}

function resetMermaidZoom() {
    const container = document.querySelector('.mermaid');
    if (!container) return;

    currentZoom = 1;
    container.style.transform = 'scale(1)';
}
