import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

const RULE_NAME = 'Wexcom Cloud Host';

export async function firewallRuleExists(port: number): Promise<boolean> {
  try {
    const { stdout } = await execAsync(
      `netsh advfirewall firewall show rule name="${RULE_NAME}"`,
      { windowsHide: true }
    );
    return stdout.includes(String(port));
  } catch {
    return false;
  }
}

export async function addFirewallRule(port: number): Promise<{ ok: boolean; message: string }> {
  try {
    const exists = await firewallRuleExists(port);
    if (exists) {
      return { ok: true, message: 'Firewall rule already exists' };
    }
    await execAsync(
      `netsh advfirewall firewall add rule name="${RULE_NAME}" dir=in action=allow protocol=TCP localport=${port}`,
      { windowsHide: true }
    );
    return { ok: true, message: `Firewall rule added for TCP port ${port}` };
  } catch (e) {
    return {
      ok: false,
      message: e instanceof Error ? e.message : String(e),
    };
  }
}
