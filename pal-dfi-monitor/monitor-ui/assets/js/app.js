async function initDashboard() {
  try {
    await Promise.all([
      renderServices(),
      renderJSON('containers', '/containers'),
      renderJSON('transactions', '/transactions')
    ]);
  } catch (err) {
    console.error(err);
  }
}

initDashboard();
setInterval(initDashboard, 10000);
