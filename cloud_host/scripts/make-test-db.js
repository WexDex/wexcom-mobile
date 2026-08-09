const { DatabaseSync } = require('node:sqlite');
const fs = require('fs');
const path = require('path');

const file = path.join(__dirname, 'test-upload.sqlite');
if (fs.existsSync(file)) fs.unlinkSync(file);

const db = new DatabaseSync(file);
db.exec(`
  CREATE TABLE clients (
    id TEXT PRIMARY KEY,
    full_name TEXT NOT NULL,
    phone TEXT,
    note TEXT,
    balance_minor INTEGER NOT NULL DEFAULT 0,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    archived_at INTEGER
  );
`);
db.prepare(
  'INSERT INTO clients (id, full_name, balance_minor, created_at, updated_at) VALUES (?, ?, ?, ?, ?)'
).run('c1', 'Alice', 1000, Date.now(), Date.now());
db.close();
console.log('Created', file);
