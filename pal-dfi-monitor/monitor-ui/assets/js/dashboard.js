async function renderServices() {
  const data = await getJSON('/services');
  const host = document.getElementById('services');
  host.innerHTML = data.map(s => `
    <div class="card ${s.status}">
      <strong>${s.name.toUpperCase()}</strong><br>
      <small>${s.url}</small><br>
      <span>Status: ${s.status}</span>
    </div>
  `).join('');
}

async function renderJSON(id, path) {
  const data = await getJSON(path);
  document.getElementById(id).textContent = JSON.stringify(data, null, 2);
}
