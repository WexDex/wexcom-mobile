import { EventEmitter } from 'events';

const MAX_LINES = 500;

export class Logger extends EventEmitter {
  private lines: string[] = [];

  log(message: string): void {
    const line = `[${new Date().toISOString()}] ${message}`;
    this.lines.push(line);
    if (this.lines.length > MAX_LINES) {
      this.lines.shift();
    }
    console.log(line);
    this.emit('log', line);
  }

  getLines(): string[] {
    return [...this.lines];
  }

  clear(): void {
    this.lines = [];
    this.emit('clear');
  }
}
