"use client";
import { useEffect } from "react";
import Link from "next/link";
import Nav from "../../components/Nav";

export default function CaseRelevancy() {
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
            <div className="section__num"><span></span>Case 01 · Ranking</div>
            <h1 className="case__title">A relevancy algorithm<br />for PLP product ranking.</h1>
            <p className="case__lede">
              How I designed and shipped a new ranking model for Tira's product
              listing pages — blending behavioural signals, freshness and
              merchandising constraints — and cut bounce on category pages by
              7–10%.
            </p>
            <div className="case__meta">
              <div><div className="k">Company</div><div className="v">Jio Beauty — Tira</div></div>
              <div><div className="k">Role</div><div className="v">Product analyst, lead on ranking</div></div>
              <div><div className="k">Timeline</div><div className="v">2024</div></div>
              <div><div className="k">Team</div><div className="v">Product · Engineering · UX</div></div>
            </div>
          </div>
        </header>

        <div className="wrap">
          <div className="case__cover">
            <svg className="cover-svg" viewBox="0 0 1200 540" preserveAspectRatio="none">
              <defs>
                <linearGradient id="bg" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0" stopColor="#161A24" />
                  <stop offset="1" stopColor="#0E1118" />
                </linearGradient>
              </defs>
              <rect width="1200" height="540" fill="url(#bg)" />
              <g stroke="#E0B973" strokeWidth="1.5" fill="none" opacity="0.5">
                <rect x="80"  y="200" width="160" height="240" />
                <rect x="260" y="200" width="160" height="240" />
                <rect x="440" y="200" width="160" height="240" fill="#E0B973" stroke="#E0B973" opacity="1" />
                <rect x="620" y="200" width="160" height="240" />
                <rect x="800" y="200" width="160" height="240" />
                <rect x="980" y="200" width="160" height="240" />
              </g>
              <g fill="#0B0E14" fontFamily="PP Object Sans" fontWeight="500" fontSize="14" letterSpacing="0.14em">
                <text x="475" y="340">RANK #1</text>
                <text x="475" y="360">RELEVANCY 0.94</text>
              </g>
              <text x="80" y="100" fill="#ECEEF3" fontFamily="PP Object Sans" fontWeight="500" fontSize="64" letterSpacing="-2">PLP relevancy</text>
              <text x="80" y="140" fill="#9CA3B4" fontFamily="PP Object Sans" fontWeight="300" fontSize="22">Ranking that earns its top slot · Tira PLP grid · 2024</text>
            </svg>
          </div>

          <div className="case__body">
            <div className="case__sidenote">
              01 · Context<br />02 · The question<br />03 · How I worked<br />04 · The model<br />05 · What we shipped<br />06 · Outcome
            </div>
            <div>
              <div className="case__section">
                <h2>The context.</h2>
                <p>
                  Tira's product listing pages are where most discovery happens —
                  the user picks a category and scans a grid. The default ranking
                  had been built early, leaned heavily on popularity, and was now
                  biased towards a familiar handful of SKUs. New launches were
                  invisible; merchandising bets weren't paying off; bounce on
                  certain categories was creeping up.
                </p>
                <p>
                  We knew there was a ranking problem. We didn't yet know which one.
                </p>
              </div>

              <div className="case__section">
                <h2>The question, sharpened.</h2>
                <p>
                  Before touching the model, I rewrote the brief with the PM into
                  four answerable questions:
                </p>
                <ul>
                  <li><b>Which categories are bleeding the most bounce?</b><span>Down to the grid and the user segment.</span></li>
                  <li><b>Which signals actually predict a click + add-to-bag, not just a click?</b><span>So we don't optimise for empty engagement.</span></li>
                  <li><b>How do we honour merchandising (new launches, brand campaigns) without breaking relevance?</b><span>The most political question; we tackled it first.</span></li>
                  <li><b>What's the smallest version of this we can A/B test in two weeks?</b><span>Constrain scope so the experiment can actually conclude.</span></li>
                </ul>
              </div>

              <div className="case__section">
                <h2>How I worked.</h2>
                <p>
                  Three weeks of analysis before any code. I pulled six months of
                  PLP clickstream from BigQuery and built a per-SKU panel — views,
                  clicks, add-to-bag, orders, returns — keyed to category, user
                  segment and time-of-day. Then a feature audit: which signals
                  had real predictive power for an order, beyond raw popularity?
                  Freshness, price-band fit, review velocity and brand affinity
                  came out on top.
                </p>
              </div>

              <div className="case__section">
                <h2>The model, in plain terms.</h2>
                <ul>
                  <li><b>A weighted relevancy score per SKU per category.</b><span>Behavioural signal × freshness decay × price-fit, normalised within category.</span></li>
                  <li><b>A merchandising "slot reserve".</b><span>The top 12 positions remain meritocratic; specific slots below can be reserved for new-launch or campaign SKUs without pushing the best performers off-screen.</span></li>
                  <li><b>A guardrail on monotony.</b><span>No more than three SKUs from the same brand inside the top 12, to avoid the "wall of one brand" effect.</span></li>
                  <li><b>A weekly re-rank cadence.</b><span>Fresh enough to reflect new behaviour, stable enough that PMs and brands can plan against it.</span></li>
                </ul>
              </div>

              <div className="case__section">
                <h2>What we shipped.</h2>
                <p>
                  A two-arm A/B test on three pilot categories — Skincare,
                  Makeup-Lips and Fragrance — for four weeks. Primary metric:
                  PLP bounce. Secondary: add-to-bag rate, top-12 CTR, brand
                  diversity in the visible grid. Guardrails on orders and returns.
                </p>
                <div className="case__metrics">
                  <div className="metric">
                    <span className="num">7–10<sup>%</sup></span>
                    <span className="lbl">Bounce rate, pilot categories</span>
                  </div>
                  <div className="metric">
                    <span className="num">+4.6<sup>%</sup></span>
                    <span className="lbl">Add-to-bag rate</span>
                  </div>
                  <div className="metric">
                    <span className="num">+11<sup>%</sup></span>
                    <span className="lbl">Visibility for new launches</span>
                  </div>
                </div>
              </div>

              <div className="case__section">
                <h2>Outcome.</h2>
                <p>
                  The new ranking was rolled out across the catalogue after the
                  pilot and remains the default to date. Bounce on the pilot
                  categories has stayed inside the new band; the merchandising
                  slot reserve is now a regular tool the brand team uses for
                  launches without bargaining with engineering.
                </p>
                <p>
                  The piece I'm proudest of: the model is small, transparent and
                  documented in one page. Anyone in the team can explain why a
                  particular SKU sits where it sits — which means we can defend
                  it, debate it, and improve it.
                </p>
              </div>
            </div>
          </div>

          <div className="next-case">
            <div>
              <div className="label">Next case</div>
              <Link href="/case/attribution">An attribution model the whole org uses →</Link>
            </div>
            <Link href="/work" className="case__back">All work</Link>
          </div>
        </div>
      </main>

      <section id="contact" className="contact">
        <div className="wrap">
          <h2 className="contact__big">
            Want to talk about<br />
            <em>your ranking model?</em><br />
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
