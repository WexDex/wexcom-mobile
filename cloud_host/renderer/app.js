/** @typedef {import('../src/electron/preload').HostConfigDto} HostConfigDto */

const $ = (id) => document.getElementById(id);

const api = window.wexcomHost;

let running = false;

function formatBytes(n) {
  if (!n || n <= 0) return '—';
  if (n < 1024) return `${n} B`;
  if (n < 1024 * 1024) return `${(n / 1024).toFixed(1)} KB`;
  return `${(n / (1024 * 1024)).toFixed(1)} MB`;
}

function formatDate(iso) {
  if (!iso) return '—';
  try {
    return new Date(iso).toLocaleString();
  } catch {
    return iso;
  }
}

async function loadConfig() {
  const cfg = await api.getConfig();
  $('portInput').value = String(cfg.port);
  $('userInput').value = cfg.user;
  $('passInput').value = cfg.pass;
  $('dataDirInput').value = cfg.dataDir;
  $('autoStartInput').checked = cfg.autoStart;
}

async function saveConfigFromForm() {
  const cfg = await api.getConfig();
  const updated = {
    ...cfg,
    port: parseInt($('portInput').value, 10) || 8787,
    user: $('userInput').value.trim() || 'admin',
    pass: $('passInput').value,
    dataDir: $('dataDirInput').value.trim(),
    autoStart: $('autoStartInput').checked,
  };
  await api.saveConfig(updated);
}

async function refreshServerInfo() {
  const info = await api.getServerInfo();
  running = info.running;
  $('statusBadge').textContent = info.running ? 'Running' : 'Stopped';
  $('statusBadge').classList.toggle('running', info.running);
  $('toggleBtn').textContent = info.running ? 'Stop server' : 'Start server';
  $('toggleBtn').classList.toggle('btn-primary', !info.running);
  $('lanUrl').textContent = info.lanUrl;
  $('lanIpHint').textContent = info.lanIp
    ? `LAN IP: ${info.lanIp}`
    : 'No LAN IP detected — use localhost for same-machine tests';
  $('snapshotCount').textContent = String(info.snapshotCount);
  $('latestUpload').textContent = formatDate(info.latestUpload);
  $('latestSize').textContent = formatBytes(info.latestSize);

  if (info.running) {
    const qr = await api.getQrDataUrl(info.lanUrl);
    $('qrImg').src = qr;
    $('qrImg').hidden = false;
    $('qrPlaceholder').hidden = true;
  } else {
    $('qrImg').hidden = true;
    $('qrPlaceholder').hidden = false;
  }

  await refreshSnapshots();
}

async function refreshSnapshots() {
  const list = await api.listSnapshots();
  const ul = $('snapshotList');
  ul.innerHTML = '';
  if (list.length === 0) {
    ul.innerHTML = '<li class="muted">No snapshots yet</li>';
    return;
  }
  for (const s of list) {
    const li = document.createElement('li');
    const label = s.label ? ` — ${s.label}` : '';
    li.innerHTML = `<span>${s.id}<br><small>${formatDate(s.uploaded_at)} · ${formatBytes(s.size_bytes)}${label}</small></span>`;
    const del = document.createElement('button');
    del.type = 'button';
    del.className = 'btn btn-sm btn-danger';
    del.textContent = 'Delete';
    del.onclick = async () => {
      if (!confirm(`Delete snapshot ${s.id}?`)) return;
      const r = await api.deleteSnapshot(s.id);
      if (!r.ok) alert(r.error || 'Delete failed');
      await refreshServerInfo();
    };
    li.appendChild(del);
    ul.appendChild(li);
  }
}

function appendLog(line) {
  const el = $('logView');
  el.textContent += line + '\n';
  el.scrollTop = el.scrollHeight;
}

async function loadLogs() {
  const lines = await api.getLogs();
  $('logView').textContent = lines.join('\n') + (lines.length ? '\n' : '');
  $('logView').scrollTop = $('logView').scrollHeight;
}

$('toggleBtn').addEventListener('click', async () => {
  $('toggleBtn').disabled = true;
  try {
    if (running) {
      await api.stopServer();
    } else {
      await saveConfigFromForm();
      const r = await api.startServer();
      if (!r.ok) alert(r.error || 'Failed to start server');
    }
    await refreshServerInfo();
  } finally {
    $('toggleBtn').disabled = false;
  }
});

$('saveBtn').addEventListener('click', async () => {
  await saveConfigFromForm();
  alert('Settings saved. Restart server if port or credentials changed.');
});

$('copyUrlBtn').addEventListener('click', async () => {
  const url = $('lanUrl').textContent;
  if (url && url !== '—') {
    await navigator.clipboard.writeText(url);
  }
});

$('pickDirBtn').addEventListener('click', async () => {
  const dir = await api.pickDataDir();
  if (dir) $('dataDirInput').value = dir;
});

$('openFolderBtn').addEventListener('click', () => api.openSnapshotsFolder());
$('refreshBtn').addEventListener('click', () => refreshServerInfo());
$('clearLogsBtn').addEventListener('click', async () => {
  await api.clearLogs();
  $('logView').textContent = '';
});

$('firewallAllowBtn').addEventListener('click', async () => {
  const r = await api.addFirewallRule();
  $('firewallDialog').close();
  if (!r.ok) alert(`Firewall: ${r.message}`);
  else appendLog(`Firewall: ${r.message}`);
});

$('firewallSkipBtn').addEventListener('click', () => {
  $('firewallDialog').close();
});

api.onLog((line) => appendLog(line));
api.onServerState(() => refreshServerInfo());
api.onFirewallPrompt(() => {
  $('firewallDialog').showModal();
});

window.addEventListener('DOMContentLoaded', async () => {
  await loadConfig();
  await loadLogs();
  await refreshServerInfo();
  setInterval(refreshServerInfo, 5000);
});
