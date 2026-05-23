const apiBase = '/api';

async function getJSON(path) {
  const res = await fetch(`${apiBase}${path}`);
  if (!res.ok) throw new Error(`Request failed: ${path}`);
  return res.json();
}
