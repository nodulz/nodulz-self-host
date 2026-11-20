import { readFile, writeFile } from 'node:fs/promises';

const [base, target, format] = process.argv.slice(2);
if (!base || !target || (format && format !== '--kubernetes')) {
  throw new Error('Usage: node playwright-seccomp.mjs upstream-profile.json nodulz-playwright.json [--kubernetes]');
}
const profile = JSON.parse(await readFile(base, 'utf8'));
if (profile.defaultAction !== 'SCMP_ACT_ERRNO' || !Array.isArray(profile.syscalls)) {
  throw new Error('Expected the Playwright Docker seccomp profile');
}
profile.syscalls.unshift({ names: ['mount', 'umount2', 'pivot_root', 'chroot'], action: 'SCMP_ACT_ALLOW', args: [] });
// Resolve the amd64 rules before passing the profile to the OCI runtime.
const result = format === '--kubernetes' ? {
  defaultAction: profile.defaultAction,
  syscalls: profile.syscalls.filter(({ includes = {}, excludes = {} }) => {
    if (Object.keys(excludes).length) return false;
    const conditions = Object.keys(includes);
    return conditions.length === 0 || (conditions.length === 1 && includes.arches?.includes('amd64'));
  }).map(({ names, action, args, errnoRet }) => ({ names, action, args, errnoRet })),
} : profile;
await writeFile(target, JSON.stringify(result, null, 2) + '\n');
