import { hello, ok } from "@crive/shared";

export default function Page() {
  return (
    <main>
      <h1>Admin</h1>
      <p>API: {process.env.NEXT_PUBLIC_API_URL}</p>
      {/* ganti cara pakai ok: panggil fungsinya */}
      <p>Shared OK: {ok()}</p>
      <p>{hello()}</p>
    </main>
  );
}
