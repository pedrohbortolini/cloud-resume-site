
AOS.init({
  anchorPlacement: 'top-left',
  duration: 1000
});

async function updateVisitorCount() {
    try {
        const response = await fetch('https://vqb0v0vgj0.execute-api.us-east-1.amazonaws.com/visitors', {
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

window.addEventListener('load', updateVisitorCount);
