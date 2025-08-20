import { ok } from '@crive/shared';

export default function Page() {
  return (
    <main>
      <h1>Admin</h1>
      <p>API: {process.env.NEXT_PUBLIC_API_URL ?? '-'}</p>
      <p>Shared OK: {ok()}</p>
    </main>
  );
}
