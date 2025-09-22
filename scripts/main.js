// Animations
AOS.init({
  anchorPlacement: 'top-left',
  duration: 1000
});

// Função para buscar e atualizar contador
async function updateVisitorCount() {
    try {
        const response = await fetch('https://p8mzzliv1b.execute-api.us-east-1.amazonaws.com/prod/visitor', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            }
        });
        
        const data = await response.json();
        document.getElementById('visitor-count').textContent = data.visits;
    } catch (error) {
        console.error('Erro ao buscar contador:', error);
        document.getElementById('visitor-count').textContent = 'Erro';
    }
}

// Chama a função quando a página carrega
window.addEventListener('load', updateVisitorCount);
