// Apply the visitor's choice before the first paint; private browsing may block storage.
try {
  document.documentElement.dataset.theme = localStorage.getItem('pontonnier-theme') === 'dark' ? 'dark' : 'light';
} catch {
  document.documentElement.dataset.theme = 'light';
}
