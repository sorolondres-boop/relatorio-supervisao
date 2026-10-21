/* Service worker: o app abre mesmo com sinal fraco. Os dados (Supabase) nunca ficam em cache. */
const VERSAO = 'rs-v4';
const BASE = ['./', 'index.html', 'manifest.webmanifest', 'supabase-config.js',
  'icon-192.png', 'icon-512.png', 'apple-touch-icon.png', 'favicon.png'];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(VERSAO).then(c => c.addAll(BASE)).then(() => self.skipWaiting()));
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys()
      .then(ks => Promise.all(ks.filter(k => k !== VERSAO).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', e => {
  const req = e.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);
  if (url.hostname.endsWith('.supabase.co') || url.hostname.endsWith('.supabase.in')) return; // dados: sempre da rede
  if (url.searchParams.has('rsv')) return; // conferência de versão nova do app: sempre da rede, sem guardar

  // Páginas: tenta a rede primeiro e, sem sinal, abre a última versão guardada.
  if (req.mode === 'navigate') {
    e.respondWith(
      fetch(req).then(r => {
        const copia = r.clone();
        caches.open(VERSAO).then(c => c.put('index.html', copia));
        return r;
      }).catch(() => caches.match('index.html').then(r => r || caches.match('./')))
    );
    return;
  }

  // Arquivos do app, biblioteca e fontes: usa o guardado e atualiza em segundo plano.
  const mesmo = url.origin === self.location.origin;
  const permitido = mesmo || url.hostname === 'cdn.jsdelivr.net' ||
    url.hostname === 'fonts.googleapis.com' || url.hostname === 'fonts.gstatic.com';
  if (!permitido) return;
  e.respondWith(
    caches.open(VERSAO).then(c => c.match(req).then(guardado => {
      const rede = fetch(req).then(r => {
        if (r && (r.ok || r.type === 'opaque')) c.put(req, r.clone());
        return r;
      }).catch(() => guardado);
      return guardado || rede;
    }))
  );
});
