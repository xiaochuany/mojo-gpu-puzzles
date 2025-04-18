document.addEventListener('DOMContentLoaded', function () {
    const codeBlocks = document.querySelectorAll('pre code');

    codeBlocks.forEach(function (codeBlock) {
        const button = document.createElement('button');
        button.className = 'copy-button';
        button.textContent = 'Copy';

        const pre = codeBlock.parentNode;
        pre.style.position = 'relative';
        pre.insertBefore(button, codeBlock);

        button.addEventListener('click', function () {
            const text = codeBlock.textContent;
            navigator.clipboard.writeText(text).then(function () {
                button.textContent = 'Copied!';
                setTimeout(function () {
                    button.textContent = 'Copy';
                }, 2000);
            });
        });
    });
});
