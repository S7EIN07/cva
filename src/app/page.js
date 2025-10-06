export default function Home() {
  return (
    <main className="container py-5">
      <header className="text-center mb-5">
        <h1 className="display-4 text-primary">Meu Site com Next.js + Bootstrap</h1>
        <p className="text-secondary">
          Um site rápido, bonito e responsivo
        </p>
      </header>

      <section className="row justify-content-center">
        <div className="col-md-8 col-lg-6">
          <div className="card shadow-sm border-0">
            <div className="card-body">
              <h5 className="card-title text-center mb-3">Sobre</h5>
              <p className="card-text text-muted">
                Só um arquivo inicial aí, pra ver como funciona o Bootstrap com Next.js.
              </p>
              <div className="text-center">
                <button className="btn btn-primary">Saiba mais</button>
              </div>
            </div>
          </div>
        </div>
      </section>

      <footer className="text-center mt-5 text-muted">
        © 2025 — Criado por <strong>Jailson Stein</strong>
      </footer>
    </main>
  );
}
