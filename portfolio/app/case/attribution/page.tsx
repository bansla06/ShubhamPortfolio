"use client";
import { useEffect } from "react";
import Link from "next/link";
import Nav from "../../components/Nav";

export default function CaseAttribution() {
  useEffect(() => {
    const io = new IntersectionObserver(
      (entries) => {
        entries.forEach((en) => {
          if (en.isIntersecting) {
            en.target.classList.add("is-visible");
            io.unobserve(en.target);
          }
        });
      },
      { threshold: 0.12 }
    );
    document.querySelectorAll(".reveal, .reveal-stagger").forEach((el) => io.observe(el));
    return () => io.disconnect();
  }, []);

  return (
    <>
      <Nav />
      <main className="case">
        <header className="case__hero">
          <div className="wrap">
            <Link href="/work" className="case__back">← Back to selected work</Link>
            <div className="section__num"><span></span>Case 02 · Attribution</div>
            <h1 className="case__title">An attribution model<br />the whole org actually uses.</h1>
            <p className="case__lede">
              A SQL-native multi-touch attribution model in BigQuery that serves
              Marketing, Branding and Strategy from a single source of truth —
              and replaced three conflicting spreadsheets.
            </p>
            <div className="case__meta">
              <div><div className="k">Company</div><div className="v">Jio Beauty — Tira</div></div>
              <div><div className="k">Role</div><div className="v">Owner, attribution layer</div></div>
              <div><div className="k">Timeline</div><div className="v">2023</div></div>
              <div><div className="k">Consumers</div><div className="v">Marketing · Branding · Strategy</div></div>
            </div>
          </div>
        </header>

        <div className="wrap">
          <div className="case__cover">
            <svg className="cover-svg" viewBox="0 0 1200 540" preserveAspectRatio="none">
              <rect width="1200" height="540" fill="#11141C" />
              <g stroke="#E0B973" strokeWidth="1.5" fill="none" opacity="0.7">
                <circle cx="120" cy="140" r="28" />
                <circle cx="120" cy="270" r="28" />
                <circle cx="120" cy="400" r="28" />
                <circle cx="600" cy="180" r="28" />
                <circle cx="600" cy="360" r="28" />
                <circle cx="1080" cy="270" r="40" fill="#E0B973" stroke="#E0B973" />
                <path d="M148 140 C 360 140, 460 180, 572 180" />
                <path d="M148 270 C 360 270, 460 270, 572 270" strokeDasharray="4 4" />
                <path d="M148 400 C 360 400, 460 360, 572 360" />
                <path d="M628 180 C 800 180, 920 240, 1040 270" />
                <path d="M628 360 C 800 360, 920 300, 1040 270" />
              </g>
              <g fill="#9CA3B4" fontFamily="PP Object Sans" fontWeight="500" fontSize="14" letterSpacing="0.12em">
                <text x="80"  y="80">SOURCES</text>
                <text x="560" y="100">TOUCHPOINTS</text>
                <text x="1020" y="200">ORDER</text>
              </g>
              <g fill="#ECEEF3" fontFamily="PP Object Sans" fontWeight="400" fontSize="14">
                <text x="80"  y="145">Paid social</text>
                <text x="80"  y="275">Direct</text>
                <text x="80"  y="405">Email</text>
                <text x="560" y="183">PLP visit</text>
                <text x="560" y="363">Add to bag</text>
              </g>
            </svg>
          </div>

          <div className="case__body">
            <div className="case__sidenote">
              01 · The problem<br />02 · The shape<br />03 · The model<br />04 · Adoption<br />05 · Outcome<br />06 · Lessons
            </div>
            <div>
              <div className="case__section">
                <h2>The problem.</h2>
                <p>
                  Tira had three different attribution stories in circulation.
                  Marketing read paid performance one way, Branding read another,
                  and Strategy maintained a quarterly spreadsheet that didn't
                  quite reconcile to either. Each was defensible on its own; none
                  were reconcilable across teams. Every meeting started with a
                  ten-minute argument about whose number was right.
                </p>
              </div>

              <div className="case__section">
                <h2>The shape.</h2>
                <p>
                  Two principles. <b>One:</b> everyone reads attribution from one
                  place. <b>Two:</b> that place is auditable end-to-end — every
                  order can be traced back to the touchpoints it credits and the
                  rules it followed.
                </p>
              </div>

              <div className="case__section">
                <h2>The model.</h2>
                <ul>
                  <li><b>Touchpoint stitching in BigQuery.</b><span>User sessions joined to order events on a 30-day attribution window. Built entirely in SQL — no proprietary tool to lock us in.</span></li>
                  <li><b>A position-based credit rule.</b><span>40% first-touch, 40% last-touch, 20% distributed across the middle. Documented, defended, and configurable for special analyses.</span></li>
                  <li><b>Channel-level overrides.</b><span>Branding campaigns get a longer view-through window; performance campaigns don't. The rules live in a config table, not in code.</span></li>
                  <li><b>An audit table.</b><span>Every order writes out its touchpoint chain and the credit split, so anyone can sanity-check a number without re-running the pipeline.</span></li>
                </ul>
              </div>

              <div className="case__section">
                <h2>Adoption.</h2>
                <p>
                  The model itself was the easy part. The harder work was getting
                  three teams who'd been using different numbers for years to
                  agree to use one. I spent four weeks running open sessions —
                  walking through the SQL, the rules, the trade-offs — and
                  shipping side-by-side reconciliations against each team's
                  existing report. The model wasn't adopted because it was
                  "better"; it was adopted because it could explain itself.
                </p>
              </div>

              <div className="case__section">
                <h2>Outcome.</h2>
                <div className="case__metrics">
                  <div className="metric"><span className="num">1</span><span className="lbl">Source of truth across 3 teams</span></div>
                  <div className="metric"><span className="num">−6<sup>days</sup></span><span className="lbl">Monthly reporting cycle</span></div>
                  <div className="metric"><span className="num">100<sup>%</sup></span><span className="lbl">Orders with auditable chain</span></div>
                </div>
                <p>
                  Six months in, the attribution layer is the default reference in
                  quarterly business reviews. The same model is now extended for
                  the Tira Treats loyalty programme — touchpoint logic ported in
                  an afternoon because the schema was designed for it.
                </p>
              </div>

              <div className="case__section">
                <h2>Lessons.</h2>
                <p>
                  An attribution model is only as good as the conversations it
                  ends. The hardest weeks weren't the modelling — they were
                  sitting in rooms with team leads, defending why a particular
                  credit rule was a deliberate choice and not a guess. Once the
                  rules were legible, the politics quietened down. The number
                  became the boring part, which is the goal.
                </p>
              </div>
            </div>
          </div>

          <div className="next-case">
            <div>
              <div className="label">Next case</div>
              <Link href="/case/ott-dashboard">Post-campaign OTT insights, automated →</Link>
            </div>
            <Link href="/work" className="case__back">All work</Link>
          </div>
        </div>
      </main>

      <section id="contact" className="contact">
        <div className="wrap">
          <h2 className="contact__big">
            Curious about<br />
            <em>your attribution stack?</em><br />
            <a href="mailto:Shubhambansla95@gmail.com">Shubhambansla95@gmail.com</a>
          </h2>
          <div className="contact__foot">
            <div>© 2026 Shubham Bansla</div>
            <div>Made with intent, in Gurugram.</div>
          </div>
        </div>
      </section>
    </>
  );
}
